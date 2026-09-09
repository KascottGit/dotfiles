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
    },
})

local volume_gesture = function(change)
    local step = math.floor(math.abs(change) + 0.5)
    if step == 0 then return end

    if change > 0 then
        -- -l 1.0 strictly limits maximum volume to 100%
        hl.exec_cmd(string.format("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ %d%%+", step))
    else
        hl.exec_cmd(string.format("wpctl set-volume @DEFAULT_AUDIO_SINK@ %d%%-", step))
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