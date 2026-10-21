
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
    hl.env("MOZ_DISABLE_RDD_SANDBOX", "1")
    -- Render on NVIDIA when the external monitor (wired to the dGPU) is connected.
    -- Otherwise the Intel iGPU renders HDMI frames and copies them across, which
    -- stutters under load. Card numbers can change between boots, so look them up
    -- by PCI vendor ID. Only evaluated at startup; re-login after (un)plugging.
    local function read_line(path)
        local f = io.open(path, "r")
        if not f then return nil end
        local v = f:read("*l")
        f:close()
        return v
    end

    local nv, intel
    for i = 0, 3 do
        local vendor = read_line("/sys/class/drm/card" .. i .. "/device/vendor")
        if vendor == "0x10de" then
            nv = i
        elseif vendor == "0x8086" then
            intel = i
        end
    end

    if nv and intel and read_line("/sys/class/drm/card" .. nv .. "-HDMI-A-1/status") == "connected" then
        hl.env("AQ_DRM_DEVICES", "/dev/dri/card" .. nv .. ":/dev/dri/card" .. intel)
    end
end
