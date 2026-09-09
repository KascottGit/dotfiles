------------------
---- MONITORS ----
------------------

-- HDMI-A-1 on the left (at origin 0x0)
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "preferred",
    position = "0x0",
    scale    = "1",
})

-- Built-in display positioned directly to the right of HDMI-A-1
hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "auto-right",
    scale    = "1.2",
})

------------------
--- WORKSPACES ---
------------------

-- 1-4: Primary workspaces. Prefer HDMI-A-1, fall back to eDP-1.
for i = 1, 4 do
    hl.workspace_rule({
        workspace  = tostring(i),
        monitor    = "HDMI-A-1,eDP-1",
        persistent = true,
    })
end

-- 5-8: Secondary monitor workspaces. Strictly on eDP-1.
for i = 5, 8 do
    hl.workspace_rule({
        workspace  = tostring(i),
        monitor    = "eDP-1",
        persistent = false, -- Disappear when unplugged / empty
    })
end