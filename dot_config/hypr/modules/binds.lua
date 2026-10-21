---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal      = "kitty"
local fileManager   = "kitty yazi"
local menu          = "pkill wofi || wofi --show drun"
local lock          = "pkill wlogout || wlogout -b 4 -c 0 -p layer-shell"
local notifications = "swaync-client -t -sw"

local hyprshot_region = "hyprshot -m region"
local hyprshort_window = "hyprshort -m window"
---------------------
---- KEYBINDINGS ----
---------------------

local mainMod       = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd(lock))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(notifications))

-- Print Screens
hl.bind("Print", hl.dsp.exec_cmd(hyprshot_region))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(hyprshort_window))


-- Reload Waybar
--hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(reload))
local reload_cmd = [[sh -c "
    killall waybar
    killall swaync
    killall hyprpaper
    killall wlogout
    sleep 0.2
    waybar &
    GDK_WAYLAND_DISABLE=ext_background_effect_manager_v1 swaync &
    hyprpaper &
    hyprctl reload
"]]
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(reload_cmd))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9] or numpad [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
local numpadCodes = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 } -- KP_1 .. KP_9, KP_0

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    local kp  = "code:" .. numpadCodes[i]
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + " .. kp, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. kp, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
-- scroll_event_delay defaults to 300ms, which drops wheel clicks that arrive faster than that
hl.config({ binds = { scroll_event_delay = 0 } })
-- Clamped to the focused monitor's existing workspaces instead of wrapping around like "e+1"/"e-1"
local function scrollWorkspace(dir)
    return function()
        local monitor = hl.get_active_monitor()
        local current = hl.get_active_workspace()
        if not monitor or not current then return end
        local target
        for _, ws in ipairs(hl.get_workspaces()) do
            if not ws.special and ws.id > 0 and ws.monitor and ws.monitor.id == monitor.id then
                if dir > 0 and ws.id > current.id and (not target or ws.id < target) then
                    target = ws.id
                elseif dir < 0 and ws.id < current.id and (not target or ws.id > target) then
                    target = ws.id
                end
            end
        end
        if target then hl.dispatch(hl.dsp.focus({ workspace = target })) end
    end
end
hl.bind(mainMod .. " + mouse_down", scrollWorkspace(1))
hl.bind(mainMod .. " + mouse_up", scrollWorkspace(-1))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + TAB", hl.dsp.focus({ monitor = "+1" }))

-- Laptop multimedia keys for volume and LCD brightness (with OSD popups)
local osd = os.getenv("HOME") .. "/.config/hypr/scripts/osd.sh"

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(osd .. " volume up 5"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(osd .. " volume down 5"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(osd .. " volume mute"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(osd .. " mic mute"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(osd .. " brightness up 5"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(osd .. " brightness down 5"), { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd(osd .. " kbd-backlight up"), { locked = true })
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd(osd .. " kbd-backlight down"), { locked = true })

-- Lock key OSDs. Runs on key release (after the state flips) and doesn't
-- swallow the key, so Caps/Num Lock still work as normal.
hl.bind("Caps_Lock", hl.dsp.exec_cmd(osd .. " caps"),
    { locked = true, release = true, non_consuming = true, ignore_mods = true })
hl.bind("Num_Lock", hl.dsp.exec_cmd(osd .. " num"),
    { locked = true, release = true, non_consuming = true, ignore_mods = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
