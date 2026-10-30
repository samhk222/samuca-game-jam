extends RefCounted
## Candle-lit UI theme, built in code so there are no binary/theme assets to maintain.

const TEXT := Color(0.93, 0.9, 0.84)
const MUTED := Color(0.62, 0.6, 0.66)
const AMBER := Color(1.0, 0.78, 0.36)
const AMBER_DIM := Color(1.0, 0.78, 0.36, 0.22)
const INK := Color(0.12, 0.08, 0.04)
const PANEL := Color(0.085, 0.078, 0.105)
const BUTTON := Color(0.14, 0.125, 0.165)
const BUTTON_HOVER := Color(0.2, 0.17, 0.2)
const DANGER := Color(1.0, 0.45, 0.38)


static func build() -> Theme:
	var theme := Theme.new()
	theme.default_font_size = 15

	theme.set_stylebox("panel", "PanelContainer", _box(PANEL, 14, AMBER_DIM, 1, 14))
	theme.set_color("font_color", "Label", TEXT)

	theme.set_stylebox("normal", "Button", _box(BUTTON, 8, Color(1, 1, 1, 0.06), 1, 8))
	theme.set_stylebox("hover", "Button", _box(BUTTON_HOVER, 8, AMBER.darkened(0.2), 1, 8))
	theme.set_stylebox("pressed", "Button", _box(AMBER, 8, AMBER, 1, 8))
	theme.set_stylebox("hover_pressed", "Button", _box(AMBER.lightened(0.1), 8, AMBER, 1, 8))
	theme.set_stylebox("disabled", "Button", _box(Color(BUTTON, 0.45), 8, Color(1, 1, 1, 0.03), 1, 8))
	theme.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	theme.set_color("font_color", "Button", TEXT)
	theme.set_color("font_hover_color", "Button", AMBER)
	theme.set_color("font_focus_color", "Button", TEXT)
	theme.set_color("font_pressed_color", "Button", INK)
	theme.set_color("font_hover_pressed_color", "Button", INK)
	theme.set_color("font_disabled_color", "Button", Color(MUTED, 0.45))

	theme.set_stylebox("normal", "LineEdit", _box(Color(0.04, 0.035, 0.05), 8, Color(1, 1, 1, 0.1), 1, 8))
	theme.set_stylebox("focus", "LineEdit", _box(Color(0, 0, 0, 0), 8, AMBER, 1, 8))
	theme.set_color("font_color", "LineEdit", AMBER)
	theme.set_color("caret_color", "LineEdit", AMBER)
	theme.set_font_size("font_size", "LineEdit", 17)

	var line := StyleBoxLine.new()
	line.color = AMBER_DIM
	line.thickness = 1
	theme.set_stylebox("separator", "HSeparator", line)
	theme.set_constant("separation", "HSeparator", 10)

	var tooltip := _box(Color(0.06, 0.055, 0.075), 6, AMBER_DIM, 1, 8)
	theme.set_stylebox("panel", "TooltipPanel", tooltip)
	theme.set_color("font_color", "TooltipLabel", TEXT)

	_label_variation(theme, "Title", AMBER, 34)
	_label_variation(theme, "Header", AMBER, 12)
	_label_variation(theme, "Muted", MUTED, 12)
	_label_variation(theme, "BigValue", AMBER, 24)
	_label_variation(theme, "Clock", TEXT, 34)
	_label_variation(theme, "Penalty", DANGER, 14)
	_label_variation(theme, "Error", DANGER, 13)
	return theme


static func _box(bg: Color, radius: int, border: Color, border_width: int, padding: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.set_corner_radius_all(radius)
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_content_margin_all(padding)
	box.content_margin_top = padding * 0.6
	box.content_margin_bottom = padding * 0.6
	return box


static func _label_variation(theme: Theme, name: String, color: Color, size: int) -> void:
	theme.set_type_variation(name, "Label")
	theme.set_color("font_color", name, color)
	theme.set_font_size("font_size", name, size)
