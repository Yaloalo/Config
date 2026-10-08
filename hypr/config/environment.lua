hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_STYLE_OVERRIDE", "Adwaita-Dark")
hl.env("NIXOS_OZONE_WL", "1")

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
