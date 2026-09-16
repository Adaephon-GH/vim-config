-- Connect this Neovim session to a Coder workspace.
--
-- The heavy lifting is done by the `coder-nvim` script in bin/ next to this
-- config (its workspace half, `coder-nvim-remote`, rides along to the remote in
-- the config sync, so there is nothing to install over there), which
-- keeps a headless Neovim running on the workspace. From a terminal you would
-- run `coder-nvim <workspace>`; this file is the "I already have Neovim open"
-- path: it forwards the server's socket and hands this UI over to it with
-- :connect. The local session keeps running headless in the background, so
-- :CoderBack returns to it.
--
-- Note this file is also loaded by the *remote* instance (the config is synced
-- there), which is why :CoderBack is defined unconditionally -- over there it
-- is the only one of these commands that makes sense.

local M = {}

local state = {
  job = nil, ---@type integer? tunnel job in the local session
  errors = {}, ---@type string[] stderr from the tunnel, for reporting
  stopping = false, ---@type boolean set by :CoderStop, so its exit is not an error
}

local function notify(msg, level)
  vim.notify("coder: " .. msg, level or vim.log.levels.INFO)
end

---Absolute path to our bin/coder-nvim, found through the runtimepath so it does
---not matter where this config is checked out or symlinked from. Falls back to
---PATH for the ~/.local/bin symlink.
---@return string
local function script()
  local found = vim.api.nvim_get_runtime_file("bin/coder-nvim", false)[1]
  return found or "coder-nvim"
end

---A one-shot timer that can only fire, and only be closed, once. The plugin
---this replaces got exactly this wrong and spun forever after its timeout.
---@param ms integer
---@param on_timeout function
---@return function cancel
local function deadline(ms, on_timeout)
  local timer = assert((vim.uv or vim.loop).new_timer())
  local done = false

  local function finish()
    if done then
      return false
    end
    done = true
    timer:stop()
    if not timer:is_closing() then
      timer:close()
    end
    return true
  end

  timer:start(
    ms,
    0,
    vim.schedule_wrap(function()
      if finish() then
        on_timeout()
      end
    end)
  )

  return function()
    finish()
  end
end

---@return string[] names
local function workspaces()
  local out = vim.fn.systemlist({ script(), "--list" })
  if vim.v.shell_error ~= 0 then
    return {}
  end
  return vim.tbl_map(function(line)
    return vim.split(line, "\t")[1]
  end, out)
end

---Open an RPC channel to another Neovim and confirm it actually answers.
---Speaking RPC rather than shelling out to `nvim --server ... --remote-expr`
---means there is no Vimscript string to quote (a nested-quote bug there used to
---break the return address silently) and no dependency on `nvim` being on PATH.
---@param addr string
---@return integer? channel nil when the address is unreachable
local function rpc_connect(addr)
  -- v:servername and our forwarded socket are both filesystem sockets; only a
  -- host:port address needs "tcp".
  local mode = (addr:find(":") and not addr:find("/")) and "tcp" or "pipe"
  local ok, chan = pcall(vim.fn.sockconnect, mode, addr, { rpc = true })
  if not ok or chan == 0 then
    return nil
  end
  if not pcall(vim.rpcrequest, chan, "nvim_get_api_info") then
    pcall(vim.fn.chanclose, chan)
    return nil
  end
  return chan
end

---Hand this UI over to the remote server. The address must have answered first:
---:connect on a dead one detaches the UI into nothing, which is unrecoverable
---from inside Neovim.
---@param sock string
local function attach(sock)
  local home = vim.v.servername

  local chan = rpc_connect(sock)
  if not chan then
    notify("server at " .. sock .. " did not answer; staying put", vim.log.levels.ERROR)
    return
  end

  -- Teach the remote instance how to get back here. It runs this same file.
  if home ~= "" then
    local ok = pcall(vim.rpcrequest, chan, "nvim_set_var", "coder_return_address", home)
    if not ok then
      notify("could not record the return address; :CoderBack will not work", vim.log.levels.WARN)
    end
  else
    notify("this session has no servername; :CoderBack will not work", vim.log.levels.WARN)
  end
  pcall(vim.fn.chanclose, chan)

  notify("attaching to " .. sock)
  vim.cmd.connect(sock)
end

---@param ws string
local function start(ws)
  if state.job then
    notify("a tunnel is already running; :CoderStop it first", vim.log.levels.WARN)
    return
  end

  state.errors = {}
  local cancel

  local job = vim.fn.jobstart({ script(), "--tunnel", ws }, {
    on_stdout = function(_, data)
      for _, line in ipairs(data or {}) do
        line = vim.trim(line)
        if line:match("%.sock$") then
          if cancel then
            cancel()
          end
          vim.schedule(function()
            attach(line)
          end)
        end
      end
    end,
    on_stderr = function(_, data)
      for _, line in ipairs(data or {}) do
        if vim.trim(line) ~= "" then
          table.insert(state.errors, line)
        end
      end
    end,
    on_exit = function(_, code)
      if cancel then
        cancel()
      end
      state.job = nil
      if state.stopping then
        state.stopping = false
        notify("tunnel to " .. ws .. " closed")
      elseif code ~= 0 then
        notify(("tunnel to %s exited (%d)\n%s"):format(ws, code, table.concat(state.errors, "\n")), vim.log.levels.ERROR)
      end
    end,
  })

  if job <= 0 then
    notify("could not run coder-nvim", vim.log.levels.ERROR)
    return
  end
  state.job = job

  -- Starting a stopped workspace is slow, so this is generous; it only has to
  -- be finite.
  cancel = deadline(180000, function()
    notify("timed out waiting for the tunnel to " .. ws, vim.log.levels.ERROR)
    if state.job then
      vim.fn.jobstop(state.job)
    end
  end)

  notify("connecting to " .. ws .. " ...")
end

function M.setup()
  vim.api.nvim_create_user_command("CoderBack", function()
    local home = vim.g.coder_return_address
    if not home or home == "" then
      notify("no return address recorded; this session was not started by :CoderStart", vim.log.levels.WARN)
      return
    end
    -- No liveness check here, unlike attaching. This command runs in the
    -- *workspace* instance, while the address is a socket on the local machine
    -- -- unreachable from here, so probing it would refuse every legitimate
    -- :CoderBack. It is the UI process (which is local) that resolves the
    -- address when :connect fires.
    vim.cmd.connect(home)
  end, { desc = "Coder: reattach this UI to the local Neovim session" })

  -- Everything below only makes sense on a machine that connects *to*
  -- workspaces. This config is synced onto the workspace too, and neither
  -- bin/coder-nvim nor the `coder` CLI distinguishes the two (workspaces ship
  -- the CLI as well), so the server sets CODER_NVIM_REMOTE to identify itself.
  if vim.env.CODER_NVIM_REMOTE then
    return
  end
  if vim.fn.executable("coder") ~= 1 then
    return
  end

  vim.api.nvim_create_user_command("CoderStart", function(opts)
    if opts.args ~= "" then
      start(opts.args)
      return
    end
    local names = workspaces()
    if vim.tbl_isempty(names) then
      notify("no workspaces found (try 'coder login')", vim.log.levels.ERROR)
      return
    end
    vim.ui.select(names, { prompt = "Coder workspace" }, function(choice)
      if choice then
        start(choice)
      end
    end)
  end, {
    nargs = "?",
    desc = "Coder: attach this UI to a workspace's Neovim",
    complete = workspaces,
  })

  vim.api.nvim_create_user_command("CoderStop", function()
    if not state.job then
      notify("no tunnel running")
      return
    end
    state.stopping = true
    vim.fn.jobstop(state.job)
  end, { desc = "Coder: close the tunnel opened by :CoderStart" })

  vim.api.nvim_create_user_command("CoderStatus", function(opts)
    local ws = opts.args
    if ws == "" then
      notify("usage: :CoderStatus <workspace>", vim.log.levels.WARN)
      return
    end
    notify(table.concat(vim.fn.systemlist({ script(), "--status", ws }), "\n"))
  end, {
    nargs = "?",
    desc = "Coder: report a workspace's Neovim server state",
    complete = workspaces,
  })
end

M.setup()

return M
