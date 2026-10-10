hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = {
                colors = {
                    "rgba(000000ff)", "rgba(ffffffff)", "rgba(000000ff)"
                },
                angle = 25,
            },
            inactive_border = "rgba(303030aa)",
        },
        resize_on_border = true,
        extend_border_grab_area = 8,
        allow_tearing = false,
        layout = "dwindle",
        snap = {
            enabled = true,
            window_gap = 8,
            monitor_gap = 12,
            border_overlap = false,
        },
    },
    decoration = {
        rounding = 14,
        rounding_power = 2,
        active_opacity = 0.97,
        inactive_opacity = 0.93,
        dim_inactive = true,
        dim_strength = 0.08,
        shadow = {
            enabled = true,
            range = 18,
            render_power = 3,
            color = 0xaa010207,
            color_inactive = 0x66000000,
        },
        blur = {
            enabled = true,
            size = 7,
            passes = 3,
            new_optimizations = true,
            ignore_opacity = true,
            brightness = 0.72,
            contrast = 1.08,
            vibrancy = 0.24,
            popups = true,
        },
    },
    dwindle = {
        preserve_split = true,
        smart_split = true,
        smart_resizing = true,
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },
})
