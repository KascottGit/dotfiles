----------------
---- NVIDIA ----
----------------

-- Performance tweaks for the MSI (RTX 3060). Skipped on machines without the
-- proprietary NVIDIA driver, so the AMD machine (YOGA) keeps its defaults.
-- Loaded last so it overrides values set in the other modules.

local f = io and io.open("/proc/driver/nvidia/version", "r")
if not f then return end
f:close()

hl.config({
    general = {
        -- Only takes effect for windows matched by an "immediate" rule below
        -- (or apps asking for it), and only while they are fullscreen.
        allow_tearing = true,
    },

    render = {
        -- 2 = let fullscreen games skip compositing entirely
        direct_scanout = 2,
    },

    cursor = {
        -- Use hardware cursor planes instead of repainting on every mouse move.
        -- If the cursor flickers or disappears, set this back to 2 (auto).
        no_hardware_cursors = 0,
    },
})

hl.window_rule({
    -- Tear instead of waiting for vsync in Steam games, for lower input latency
    name      = "steam-games-tearing",
    match     = { class = "^steam_app_[0-9]+$" },

    immediate = true,
})
