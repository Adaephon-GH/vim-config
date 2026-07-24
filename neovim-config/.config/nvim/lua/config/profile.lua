-- Host profile -> enabled language groups.
--
-- "Core" languages (Python, shell, JS, YAML/k8s/Helm, JSON, XML, Markdown/reST,
-- SQL, TOML) are always on. Heavier / situational groups are toggled per host so
-- that lazy.nvim doesn't clone and Mason doesn't try to install servers/toolchains
-- you don't have on that machine (e.g. no Rust on the work box, no Odoo at home).
--
-- Selection order:
--   1. $NVIM_PROFILE, if it names a known profile
--   2. a hostname match in `hosts` below
--   3. "home" (default)
-- Then lua/config/local.lua (git-ignored) may override the profile and/or patch
-- individual groups. See lua/config/local.lua.example.

local M = {}

-- Optional language groups (core is implicit and always enabled).
local profiles = {
  home  = { rust = true,  haskell = true,  latex = true,  odoo = false, terraform = false },
  work  = { rust = false, haskell = false, latex = false, odoo = true,  terraform = true },
  coder = { rust = true,  haskell = true,  latex = true,  odoo = true,  terraform = true },
}

-- Map exact hostnames to a profile (optional; edit to taste or use $NVIM_PROFILE).
local hosts = {
  -- ["my-work-laptop"] = "work",
}

local function detect()
  local env = vim.env.NVIM_PROFILE
  if env and profiles[env] then
    return env
  end
  local host = (vim.uv or vim.loop).os_gethostname()
  if host and hosts[host] then
    return hosts[host]
  end
  return "home"
end

M.name = detect()
M.groups = vim.deepcopy(profiles[M.name] or profiles.home)

-- Machine-specific override: lua/config/local.lua may return e.g.
--   return { profile = "work", groups = { odoo = false } }
local ok, override = pcall(require, "config.local")
if ok and type(override) == "table" then
  if override.profile and profiles[override.profile] then
    M.name = override.profile
    M.groups = vim.deepcopy(profiles[override.profile])
  end
  for k, v in pairs(override.groups or {}) do
    M.groups[k] = v
  end
end

--- Is an optional language group enabled on this host?
function M.has(group)
  return M.groups[group] == true
end

return M
