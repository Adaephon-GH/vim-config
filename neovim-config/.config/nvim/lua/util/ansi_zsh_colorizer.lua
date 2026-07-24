---@mod ansi_zsh_colorizer Custom colorizer parser
---@brief [[
---Custom nvim-colorizer.lua parser covering:
---  - The same escape formats as the plugin's built-in `xterm` parser
---    (#xNN, \e[38;5;NNNm, \e[48;5;NNNm, \e[38;2;R;G;Bm, \e[48;2;R;G;Bm, \e[X;Ym)
---  - ansi:<name> / ansi:<name>Bright
---  - zsh prompt fg/bg: %F{<name>}, %K{<name>}, %F{<number>}, %K{<number>}
---
---Colors 0-15 are sourced from vim.g.terminal_color_0..15 (falls back to the
---plugin's stock ANSI values if a slot isn't set); colors 16-255 use the
---standard xterm 6x6x6 cube / grayscale ramp, same as everywhere else.
---
---Wired up in lua/plugins/editor.lua's colorizer spec:
---  opts = {
---    options = {
---      parsers = {
---        xterm = { enable = false }, -- keep built-in disabled, this replaces it
---        custom = { require("util.ansi_zsh_colorizer") },
---      },
---    },
---  }
---@brief ]]

local color_indices = {
  black = 0,
  red = 1,
  green = 2,
  yellow = 3,
  blue = 4,
  magenta = 5,
  cyan = 6,
  white = 7,
}

-- Stock ANSI 0-15 values (same as nvim-colorizer.lua's built-in xterm parser),
-- used as a fallback for any slot vim.g.terminal_color_N doesn't define.
local default_base16 = {
  "000000",
  "800000",
  "008000",
  "808000",
  "000080",
  "800080",
  "008080",
  "c0c0c0",
  "808080",
  "ff0000",
  "00ff00",
  "ffff00",
  "0000ff",
  "ff00ff",
  "00ffff",
  "ffffff",
}

local palette = {}

local function build_palette()
  -- 0-15: from the terminal's actual palette (g:terminal_color_N = "#rrggbb")
  for i = 0, 15 do
    local tc = vim.g["terminal_color_" .. i]
    if type(tc) == "string" then
      palette[i + 1] = tc:gsub("^#", "")
    else
      palette[i + 1] = default_base16[i + 1]
    end
  end
  -- 16-231: 6x6x6 color cube
  local function scale(x)
    return x == 0 and 0 or 95 + 40 * (x - 1)
  end
  for r = 0, 5 do
    for g = 0, 5 do
      for b = 0, 5 do
        local idx = 16 + 36 * r + 6 * g + b
        palette[idx + 1] = string.format("%02x%02x%02x", scale(r), scale(g), scale(b))
      end
    end
  end
  -- 232-255: grayscale ramp
  for i = 0, 23 do
    local level = 8 + i * 10
    palette[233 + i] = string.format("%02x%02x%02x", level, level, level)
  end
end

build_palette()

-- Colorscheme changes commonly re-set g:terminal_color_*; keep the palette in sync.
-- Note: already-highlighted buffers won't repaint until colorizer re-parses them
-- (e.g. on next edit/attach) - trigger `:ColorizerReloadAllBuffers` if you want
-- an immediate refresh after switching colorschemes.
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = build_palette,
})

--- Resolve "black" / "greenBright" / etc. to a 0-255 palette index.
---@param name string
---@return number|nil
local function name_to_index(name)
  local base_name, bright = name:match("^(%a-)(Bright)$")
  base_name = base_name or name
  local idx = color_indices[base_name]
  if not idx then
    return nil
  end
  return bright and (idx + 8) or idx
end

local ansi_256_fg_patterns = {
  "^\\e%[38;5;(%d?%d?%d)m",
  "^\27%[38;5;(%d?%d?%d)m",
}
local ansi_256_bg_patterns = {
  "^\\e%[48;5;(%d?%d?%d)m",
  "^\27%[48;5;(%d?%d?%d)m",
}
local ansi_truecolor_patterns = {
  "^\\e%[38;2;(%d+);(%d+);(%d+)m",
  "^\27%[38;2;(%d+);(%d+);(%d+)m",
  "^\\e%[48;2;(%d+);(%d+);(%d+)m",
  "^\27%[48;2;(%d+);(%d+);(%d+)m",
}
local ansi_16_patterns = {
  "^\\e%[(%d+);(%d+)m",
  "^\27%[(%d+);(%d+)m",
}

local M = {}

---@param ctx colorizer.ParserContext
---@return number|nil, string|nil
function M.parse(ctx)
  local line, i = ctx.line, ctx.col

  -- #xNN (decimal, 0-255)
  if line:byte(i) == 0x23 then -- '#'
    if line:byte(i + 1) == 0x78 then -- 'x'
      local num = line:sub(i + 2):match("^(%d?%d?%d)")
      if num then
        local idx = tonumber(num)
        if idx and idx >= 0 and idx <= 255 then
          local next_byte = line:byte(i + 2 + #num)
          if
            not next_byte
            or not (
              (next_byte >= 0x30 and next_byte <= 0x39)
              or (next_byte >= 0x41 and next_byte <= 0x5A)
              or (next_byte >= 0x61 and next_byte <= 0x7A)
              or next_byte == 0x5F
            )
          then
            return 2 + #num, palette[idx + 1]
          end
        end
      end
    end
    return nil
  end

  local rest = line:sub(i)

  -- \e[38;5;NNNm
  for _, pat in ipairs(ansi_256_fg_patterns) do
    local num = rest:match(pat)
    if num then
      local idx = tonumber(num)
      if idx and idx >= 0 and idx <= 255 then
        local _, e = rest:find(pat)
        return e, palette[idx + 1]
      end
    end
  end
  -- \e[48;5;NNNm
  for _, pat in ipairs(ansi_256_bg_patterns) do
    local num = rest:match(pat)
    if num then
      local idx = tonumber(num)
      if idx and idx >= 0 and idx <= 255 then
        local _, e = rest:find(pat)
        return e, palette[idx + 1]
      end
    end
  end
  -- \e[38;2;R;G;Bm / \e[48;2;R;G;Bm
  for _, pat in ipairs(ansi_truecolor_patterns) do
    local r, g, b = rest:match(pat)
    if r then
      r, g, b = tonumber(r), tonumber(g), tonumber(b)
      if r <= 255 and g <= 255 and b <= 255 then
        local _, e = rest:find(pat)
        return e, string.format("%02x%02x%02x", r, g, b)
      end
    end
  end
  -- \e[X;Ym (16-color, foreground 30-37 / background 40-47, brightness 0-1)
  for _, pat in ipairs(ansi_16_patterns) do
    local mx, my = rest:match(pat)
    if mx and my then
      local x, y = tonumber(mx), tonumber(my)
      local color, brightness = math.max(x, y), math.min(x, y)
      if brightness == 0 or brightness == 1 then
        if color >= 30 and color <= 37 then
          local _, e = rest:find(pat)
          return e, palette[(color - 30) + 1 + brightness * 8]
        elseif color >= 40 and color <= 47 then
          local _, e = rest:find(pat)
          return e, palette[(color - 40) + 1 + brightness * 8]
        end
      end
    end
  end

  -- ansi:<name> / ansi:<name>Bright
  local ansi_name = rest:match("^ansi:(%a+)")
  if ansi_name then
    local idx = name_to_index(ansi_name)
    if idx then
      return 5 + #ansi_name, palette[idx + 1]
    end
  end

  -- zsh prompt colors: %F{<name>|<number>}, %K{<name>|<number>}
  local zsh_kind, zsh_body = rest:match("^%%([FK]){([^}]*)}")
  if zsh_kind then
    local hex
    local num = zsh_body:match("^(%d+)$")
    if num then
      local idx = tonumber(num)
      if idx and idx >= 0 and idx <= 255 then
        hex = palette[idx + 1]
      end
    else
      local idx = name_to_index(zsh_body)
      if idx then
        hex = palette[idx + 1]
      end
    end
    if hex then
      return 4 + #zsh_body, hex
    end
  end

  return nil
end

M.spec = {
  name = "ansi_zsh",
  prefix_bytes = { 0x23 }, -- '#' for #xNN
  prefixes = { "\27[", "\\e[", "ansi:", "%F{", "%K{" },
  parse = M.parse,
}

return M.spec
