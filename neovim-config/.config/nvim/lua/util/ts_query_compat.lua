---@mod ts_query_compat Treesitter query-handler compatibility for Neovim 0.12
---@brief [[
---Reinstates the `all = false` option of |vim.treesitter.query.add_predicate()|
---and |vim.treesitter.query.add_directive()|.
---
---Until Neovim 0.11 that option wrapped a handler so every capture reached it as
---a single TSNode. Since 0.11 a capture is a *list* of nodes, and 0.12 dropped
---the option entirely -- its add_predicate()/add_directive() know only `force`.
---A handler written against the old API then receives a table where it expects a
---node, and the parse dies with:
---
---  vim/treesitter.lua: attempt to call method 'range' (a nil value)
---
---nvim-treesitter's `master` branch is frozen at "Neovim 0.10 or 0.11" and still
---registers all of its predicates with `{ force = true, all = false }`, so on
---0.12 every injection routed through one of them breaks: fenced code blocks
---with a language tag (markdown), heredocs (bash, hcl/terraform), and
---`<script type=...>` (html) all fail to parse and lose their highlighting.
---
---The conversion below is the one Neovim 0.11 did, kept deliberately literal:
---each capture collapses to `v[#v]`, the *last* node of the list. The two
---wrappers are not symmetric -- the predicate one converts numeric keys only and
---passes the handler's verdict back, the directive one converts every key and
---discards the result.
---
---Only callers that explicitly ask for `all = false` are affected, so handlers
---written against the current API keep receiving their lists.
---
---Wired up in lua/plugins/treesitter.lua, from the nvim-treesitter spec's
---`init`, so it is in place before the plugin registers anything.
---
---Delete this module once nvim-treesitter moves to its `main` branch. That needs
---the tree-sitter CLI (>= 0.26.1) for every parser build, whose released Linux
---binaries want glibc 2.39 -- more than Ubuntu 22.04 has, so it is out of reach
---on this host until the OS is newer.
---@brief ]]

local M = {}

local installed = false

---Collapse each capture's node list to its last node, as Neovim <= 0.11 did.
---@param match table<integer, TSNode[]>
---@param numeric_keys_only boolean
---@return table<integer, TSNode>
local function single_nodes(match, numeric_keys_only)
  local m = {}
  for k, v in pairs(match) do
    if not numeric_keys_only or type(k) == "number" then
      m[k] = v[#v]
    end
  end
  return m
end

---True for the new-style opts table that asks for the removed behaviour. The
---pre-0.10 signature passed `force` as a bare boolean, hence the type check.
local function wants_single_nodes(opts)
  return type(opts) == "table" and opts.all == false
end

function M.setup()
  -- Nothing to paper over before 0.12: there the option still works.
  if installed or vim.fn.has("nvim-0.12") == 0 then
    return
  end
  installed = true

  local query = vim.treesitter.query
  local add_predicate, add_directive = query.add_predicate, query.add_directive

  query.add_predicate = function(name, handler, opts)
    if wants_single_nodes(opts) then
      local inner = handler
      handler = function(match, ...)
        return inner(single_nodes(match, true), ...)
      end
    end
    return add_predicate(name, handler, opts)
  end

  query.add_directive = function(name, handler, opts)
    if wants_single_nodes(opts) then
      local inner = handler
      handler = function(match, ...)
        inner(single_nodes(match, false), ...)
      end
    end
    return add_directive(name, handler, opts)
  end
end

return M
