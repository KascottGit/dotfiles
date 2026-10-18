
-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Toolkit backend
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- XTG
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- QT
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1.2")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

hl.env("EDITOR", "micro")
hl.env("VISUAL", "micro")

hl.env("GDK_DEBUG","portals")
hl.env("GTK_USE_PORTAL","1")

-- NVIDIA (MSI only)
-- See https://wiki.hypr.land/Nvidia/
-- Only applied when the proprietary NVIDIA driver is loaded, so this file
-- stays safe on the AMD machine (YOGA).
local function has_nvidia()
    if not io then return false end
    local f = io.open("/proc/driver/nvidia/version", "r")
    if f then
        f:close()
        return true
    end
    return false
end

if has_nvidia() then
    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    hl.env("NVD_BACKEND", "direct")              -- nvidia-vaapi-driver
    hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
end
