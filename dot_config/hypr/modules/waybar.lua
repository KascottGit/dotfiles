----------------
---- WAYBAR ----
----------------

-- Waybar sets "exclusive": false so swaync's control center covers it (and
-- swallows clicks on it) while open. The bar's 40px is part of gaps_out in decorations.lua.

-- Popups opened from the bar (~/.config/waybar/scripts/popup.sh).
-- They stay normal windows (layers get no border or rounding) but dim the
-- screen like swaync, and keep focus so focus-follows-mouse can't steal it.
-- Closed by a click elsewhere, see the mouse binds below.
hl.window_rule({
  name         = "waybar-popups",
  match        = { class = "^waybar-popup-.*$" },
  float        = true,
  dim_around   = true,
  stay_focused = true,
})

-- Right-hand popups sit over the swaync control center:
-- 360px wide, 36px from the right edge, 36px under the bar (40px), 500px off the bottom.
-- Sizes are inside the 2px border, so each side is 2px in from swaync's box.
hl.window_rule({
  name    = "waybar-panels",
  match   = { class = "^waybar-popup-(bluetui|pulsemixer|nmtui)$" },
  size    = "356 monitor_h-580",
  move    = "monitor_w-394 78",
})

-- Left-hand popups mirror that: 36px from the left edge, 36px under the bar
hl.window_rule({
  name    = "waybar-calendar",
  match   = { class = "^waybar-popup-calendar$" },
  size    = {230, 190},
  move    = "38 78",
})

hl.window_rule({
  name    = "waybar-media",
  match   = { class = "^waybar-popup-media$" },
  size    = {356, 210},
  move    = "38 78",
})

-- The custom workspace buttons only redraw when told to
local function refreshWorkspaces()
  hl.exec_cmd("pkill -RTMIN+8 waybar")
end

for _, event in ipairs({
  "workspace.active",
  "workspace.created",
  "workspace.removed",
  "workspace.move_to_monitor",
  "monitor.focused",
}) do
  hl.on(event, refreshWorkspaces)
end

-- Close bar popups on a click outside them. Clicks on the bar are left alone,
-- its buttons toggle the popups themselves.
local function contains(x, y, w, h, pos)
  return pos.x >= x and pos.x < x + w and pos.y >= y and pos.y < y + h
end

local function closePopupsOnClickAway()
  local popups = {}
  for _, window in ipairs(hl.get_windows()) do
    if window.class:find("^waybar%-popup%-") then table.insert(popups, window) end
  end
  if #popups == 0 then return end

  local pos = hl.get_cursor_pos()
  if not pos then return end
  for _, bar in ipairs(hl.get_layers({ namespace = "waybar" })) do
    if contains(bar.x, bar.y, bar.w, bar.h, pos) then return end
  end
  for _, popup in ipairs(popups) do
    if contains(popup.at.x, popup.at.y, popup.size.x, popup.size.y, pos) then return end
  end

  for _, popup in ipairs(popups) do
    hl.exec_cmd("kill " .. popup.pid)
  end
end

hl.bind("mouse:272", closePopupsOnClickAway, { non_consuming = true })
hl.bind("mouse:273", closePopupsOnClickAway, { non_consuming = true })
