hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

if hl.plugin.hyprglass then
    local hg = hl.plugin.hyprglass

    hg.config({
        default_theme = "dark",
        default_preset = "glass",


        layers = { enabled = true },
    })

    local layer_opts = {
        preset = "glass",
        mask_threshold = 0.1
    }

    hg.layer("wofi", layer_opts)
    hg.layer("logout_dialog", layer_opts)
    hg.layer("swaync-control-center", layer_opts)
    hg.layer("swaync-notification_window", layer_opts)

    -- Presets
    hg.preset("glass", {
        glass_opacity = 1,
        blur_strength = 0.5,
        refraction_strength = 1,
        chromatic_aberration = 0.2,
        fresnel_strength = 1,
        specular_strength = 2,
        lens_distortion = 0,
        dark = { brightness = 0.8, contrast = 1, saturation = 1, vibrancy = 1, adaptive_dim = 0 },
    })
end
