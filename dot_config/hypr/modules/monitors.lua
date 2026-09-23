------------------
---- MONITORS ----
------------------

-- HDMI-A-1 on the left (at origin 0x0)
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@74.97Hz",
    position = "0x0",
    scale    = "1",
})

-- Built-in display positioned directly to the right of HDMI-A-1
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60.02Hz",
    position = "auto-right",
    scale    = "1.2",
})

------------------
--- WORKSPACES ---
------------------

-- Helper to clear all workspace rules (1-8)
local function clear_workspace_rules()
    for i = 1, 8 do
        hl.workspace_rule({ workspace = tostring(i) })
    end
end

-- Laptop-only setup: workspaces 1-4 on eDP-1, persistent, default = 1
local function setup_laptop_only()
    clear_workspace_rules()
    for i = 1, 4 do
        hl.workspace_rule({
            workspace  = tostring(i),
            monitor    = "eDP-1",
            persistent = true,
        })
    end
    hl.workspace_rule({
        workspace = "1",
        monitor   = "eDP-1",
        default   = true,
    })
end

-- Dual-monitor setup: 1-4 on HDMI, 5-8 on eDP-1, both persistent
local function setup_dual_monitor()
    clear_workspace_rules()
    -- Workspaces 1-4 on HDMI
    for i = 1, 4 do
        hl.workspace_rule({
            workspace  = tostring(i),
            monitor    = "HDMI-A-1",
            persistent = true,
        })
    end
    -- Workspaces 5-8 on eDP-1
    for i = 5, 8 do
        hl.workspace_rule({
            workspace  = tostring(i),
            monitor    = "eDP-1",
            persistent = true,
        })
    end
    -- Default workspaces
    hl.workspace_rule({
        workspace = "1",
        monitor   = "HDMI-A-1",
        default   = true,
    })
    hl.workspace_rule({
        workspace = "5",
        monitor   = "eDP-1",
        default   = true,
    })
end

-- Initial setup based on current monitor state
if hl.get_monitor("HDMI-A-1") ~= nil then
    setup_dual_monitor()
else
    setup_laptop_only()
end

-- React to monitor hotplug events
hl.on("monitor.added", function(monitor)
    if monitor.name == "HDMI-A-1" then
        setup_dual_monitor()
    end
end)

hl.on("monitor.removed", function(monitor)
    if monitor.name == "HDMI-A-1" then
        setup_laptop_only()
    end
end)
