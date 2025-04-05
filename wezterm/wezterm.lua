-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.audible_bell = "Disabled"
config.initial_cols = 200
config.initial_rows = 100
config.font_size = 13.0

-- and finally, return the configuration to wezterm
return config
