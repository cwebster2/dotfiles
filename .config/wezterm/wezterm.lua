local wezterm = require 'wezterm';
local config = {}

config.font_size = 11.0
config.font = wezterm.font("Monaspace Neon", {weight="Light"})

-- override the fonts for e.g. italic rendering
-- config.font_rules = {
--   {
--     italic = true,
--     intensity = "Normal",
--     font = wezterm.font("Monaspace Radon", {weight="Light", italic=true})
--   },
--   {
--     italic = true,
--     intensity = "Half",
--     font = wezterm.font("Monaspace Radon", {weight="ExtraLight", italic=true})
--   },
--   {
--     italic = true,
--     intensity = "Bold",
--     font = wezterm.font("Monaspace Radon", {weight="Bold", italic=true})
--   },
-- }

config.window_background_opacity = 0.8

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
custom.background = "#000000"
custom.tab_bar = {
  background = "#000000",
  active_tab = {
    fg_color = "#0e90ff",
    bg_color = "#000000",
    -- underline = "Single",
  },
  inactive_tab = {
    fg_color = "#545c7e",
    bg_color = "#000000",
  },
  new_tab = {
    fg_color = "#545c7e",
    bg_color = "#000000",
  },
}
config.color_schemes = {
  ["custom"] = custom,
}
config.color_scheme = "custom"

return config
