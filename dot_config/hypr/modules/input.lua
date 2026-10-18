---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout    = "se",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "",
        kb_rules     = "",

        follow_mouse = 1,

        sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad     = {
            natural_scroll = true,
        },

        numlock_by_default = true,
    },
})

local osd = os.getenv("HOME") .. "/.config/hypr/scripts/osd.sh"

local volume_gesture = function(change)
    local step = math.floor(math.abs(change) + 0.5)
    if step == 0 then return end

    -- osd.sh caps "up" at 100% and shows the volume popup
    if change > 0 then
        hl.exec_cmd(string.format("%s volume up %d", osd, step))
    else
        hl.exec_cmd(string.format("%s volume down %d", osd, step))
    end
end

hl.gesture({
    fingers = 3,
    direction = "vertical",
    action = {
        start = function(e) volume_gesture(-0.25 * e.delta.y) end,
        update = function(e) volume_gesture(-0.25 * e.delta.y) end
    }
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

hl.config({
    gestures = {
        workspace_swipe_forever = true,
    }
})

hl.device({
    name = "logitech-g305-1",
    accel_profile = "flat",
    sensitivity = 0, -- Adjust if base DPI speed is too fast/slow (-1.0 to 1.0)
})