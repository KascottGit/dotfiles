-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("udiskie --tray")
    hl.exec_cmd("GDK_WAYLAND_DISABLE=ext_background_effect_manager_v1 swaync")
end)
