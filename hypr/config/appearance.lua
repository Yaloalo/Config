local eva = require("config.mode").current() == "eva"

-- Star: black/white glass with soft corners. Eva: NERV orange, square corners.
local border = eva
    and { colors = { "rgba(ff7e1aff)", "rgba(b35a12ff)", "rgba(ff7e1aff)" }, angle = 25 }
    or { colors = { "rgba(000000ff)", "rgba(ffffffff)", "rgba(000000ff)" }, angle = 25 }

hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = border,
            inactive_border = eva and "rgba(5c2508aa)" or "rgba(303030aa)",
        },
        resize_on_border = true,
        extend_border_grab_area = 8,
        allow_tearing = false,
        layout = "scrolling",
        snap = {
            enabled = true,
            window_gap = 8,
            monitor_gap = 12,
            border_overlap = false,
        },
    },
    decoration = {
        rounding = eva and 0 or 14,
        rounding_power = 2,
        active_opacity = 0.97,
        inactive_opacity = 0.93,
        dim_inactive = true,
        dim_strength = 0.08,
        shadow = {
            enabled = true,
            range = 18,
            render_power = 3,
            color = eva and 0xaa1a0b04 or 0xaa010207,
            color_inactive = 0x66000000,
        },
        blur = {
            enabled = true,
            -- Preserve small wallpaper stars instead of blurring them to black.
            size = 1,
            passes = 1,
            new_optimizations = true,
            ignore_opacity = true,
            brightness = 1.0,
            contrast = 1.0,
            vibrancy = 0.24,
            popups = true,
        },
    },
    dwindle = {
        preserve_split = true,
        smart_split = true,
        smart_resizing = true,
    },
    scrolling = {
        -- Each new tiled window gets its own side-by-side column.
        direction = "right",
        column_width = 0.5,
        fullscreen_on_one_column = true,
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        -- Never strand the session on dark screens: any key wakes them.
        key_press_enables_dpms = true,
    },
})
