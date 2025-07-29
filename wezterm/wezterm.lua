-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.animation_fps = 1
config.audible_bell = "Disabled"
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.font_size = 12.0
config.initial_cols = 200
config.initial_rows = 100
config.max_fps = 30
config.window_close_confirmation = "NeverPrompt"

config.keys = {
    -- Disable Cmd+Ctrl+F (macOS native full-screen shortcut)
    {
        key = "f",
        mods = "CMD|CTRL",
        action = wezterm.action.DisableDefaultAssignment,
    },
}

-- and finally, return the configuration to wezterm
return config
