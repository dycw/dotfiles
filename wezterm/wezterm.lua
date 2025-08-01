local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- always
config.audible_bell = "Disabled"
config.font_size = 12.0
config.initial_cols = 200
config.initial_rows = 100
config.keys = {
    {
        key = "f",
        mods = "CMD|CTRL",
        action = wezterm.action.DisableDefaultAssignment,
    },
}
config.window_close_confirmation = "NeverPrompt"

-- conditional
if wezterm.hostname() == "RH-MacBook" then
    config.allow_win32_input_mode = false
    config.animation_fps = 1
    config.cursor_blink_ease_in = "Constant"
    config.cursor_blink_ease_out = "Constant"
    config.enable_scroll_bar = false
    config.font_size = 11.0 -- smaller
    config.freetype_load_target = "Light"
    config.freetype_render_target = "HorizontalLcd"
    config.macos_window_background_blur = 0
    config.max_fps = 30
    config.window_background_opacity = 1.0
    config.window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    }
end
return config
