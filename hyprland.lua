-- Hyprland Lua config
-- Edit this file directly; home.nix just loads it via require("config").

-- ── Monitor ───────────────────────────────────────────────────────────
hl.monitor({
  output = "DP-1",
  mode = "5120x1440@144",
  position = "0x0",
  scale = 1,
})

-- ── Config ────────────────────────────────────────────────────────────
hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 0,
    border_size = 1,
    layout = "scrolling",
    col = {
      active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "0xffffffff",
    },
    resize_on_border = false,
  },

  scrolling = {
    fullscreen_on_one_column = false,
    follow_min_visible = 0.4,
    explicit_column_widths = "0.25, 0.333, 0.5, 0.666, 1.0",
  },

  decoration = {
    rounding = 0,
    shadow = { enabled = true },
    blur = { enabled = true, size = 3, passes = 1 },
    inactive_opacity = 0.8,
    dim_inactive = true,
    dim_strength = 0.1,
  },

  input = {
    kb_layout = "us",
    follow_mouse = 1,
    scroll_factor = 1.0,
    touchpad = {
      tap_to_click = true,
      natural_scroll = true,
    },
  },

  animations = { enabled = true },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
  },
})

-- ── Animations ────────────────────────────────────────────────────────
hl.curve("ease", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "ease" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "ease", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "ease" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "ease" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "ease" })

-- ── Workspace Rules ───────────────────────────────────────────────────
-- Scrolling layout set both globally (general.layout) and per-workspace
for i = 1, 9 do
  hl.workspace_rule({ workspace = i, layout = "scrolling" })
end

-- ── Window Rules ──────────────────────────────────────────────────────
hl.window_rule({ match = { class = "^(authentication-agent-1)$" }, float = true })
hl.window_rule({ match = { class = "^(pwvucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(steam)$" }, float = true })
hl.window_rule({ match = { class = "^(yazi-picker)$" }, float = true, move = "300 200" })
hl.window_rule({ match = { title = "^.*(DEBUG)$" }, float = true })
hl.window_rule({ match = { class = "^(Emulator)$" }, float = true })

-- ── Autostart ─────────────────────────────────────────────────────────
hl.on("hyprland.start", function()
  hl.exec_cmd("elephant")
  hl.exec_cmd("walker --gapplication-service")
end)

-- ── Keybindings ───────────────────────────────────────────────────────
local mod = "SUPER"

-- App launchers
hl.bind(mod .. " + Return", hl.dsp.exec_cmd("ghostty"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd("ghostty --class=yazi -e yazi"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("zen-beta"))
hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd("walker"))

-- Window management
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))

-- Focus (hl.dsp.layout = layoutmsg for the scrolling layout)
hl.bind(mod .. " + H", hl.dsp.layout("focus l"))
hl.bind(mod .. " + L", hl.dsp.layout("focus r"))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + left", hl.dsp.layout("focus l"))
hl.bind(mod .. " + right", hl.dsp.layout("focus r"))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))

-- Move windows
hl.bind(mod .. " + SHIFT + H", hl.dsp.layout("swapcol l"))
hl.bind(mod .. " + SHIFT + L", hl.dsp.layout("swapcol r"))
hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "u" }))

-- Column sizing (scrolling layout)
hl.bind(mod .. " + R", hl.dsp.layout("colresize +conf"))
hl.bind(mod .. " + SHIFT + R", hl.dsp.layout("colresize -conf"))
hl.bind(mod .. " + F", hl.dsp.layout("colresize 1.0"))
hl.bind(mod .. " + period", hl.dsp.layout("promote"))
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen(1))
hl.bind(mod .. " + CTRL + SHIFT + F", hl.dsp.window.fullscreen(0))

-- Workspaces
for i = 1, 9 do
  hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + CTRL + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Screenshots
hl.bind(mod .. " + S", hl.dsp.exec_cmd("grimblast --notify copysave area"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("grimblast --notify copysave output"))
hl.bind("ALT + Print", hl.dsp.exec_cmd("grimblast --notify copysave active"))

-- Mouse
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
