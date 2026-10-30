extends RefCounted
## Draws one candle inside a box of `size` centered on `center`: wax body at the
## bottom, wick and flame on top. `diff` is "" for a normal candle, or one of
## the difficulty diffs for the unique candle.

const WAX := Color(0.96, 0.91, 0.8)
const WAX_SHADE := Color(0.82, 0.75, 0.62)
const WICK := Color(0.12, 0.1, 0.08)
const FLAME := Color(1.0, 0.82, 0.3)
const FLAME_CORE := Color(1.0, 0.97, 0.8)
const FLAME_BLUE := Color(0.45, 0.72, 1.0)
const FLAME_ORANGE := Color(1.0, 0.52, 0.12)
const GLOW := Color(1.0, 0.75, 0.35, 0.1)
const DRIP := Color(0.85, 0.32, 0.22)
const SMOKE := Color(0.6, 0.6, 0.65, 0.5)


static func draw(ci: CanvasItem, center: Vector2, size: Vector2, diff: String, time: float) -> void:
	var top_left := center - size / 2.0
	var body_top := top_left.y + size.y * 0.4
	var body := Rect2(top_left.x, body_top, size.x, size.y * 0.6)
	ci.draw_rect(body, WAX)
	ci.draw_rect(Rect2(body.position.x + body.size.x * 0.68, body.position.y, body.size.x * 0.32, body.size.y), WAX_SHADE)

	if diff == "wax_drip":
		var drip_x := body.position.x + body.size.x * 0.12
		ci.draw_rect(Rect2(body.position.x, body_top, size.x, size.y * 0.06), DRIP)
		ci.draw_rect(Rect2(drip_x, body_top, size.x * 0.3, size.y * 0.32), DRIP)
		ci.draw_circle(Vector2(drip_x + size.x * 0.15, body_top + size.y * 0.32), size.x * 0.17, DRIP)

	var wick_base := Vector2(center.x, body_top)
	var wick_length := size.y * 0.09
	var wick_dir := Vector2.UP
	if diff == "wick_bent":
		wick_dir = Vector2.UP.rotated(deg_to_rad(60.0))
		wick_length *= 2.4
	var wick_tip := wick_base + wick_dir * wick_length
	ci.draw_line(wick_base, wick_tip, WICK, maxf(2.0, size.x * 0.14))

	# The "no_wick" diff is an unlit candle: wick and a wisp of smoke, no flame.
	if diff == "no_wick":
		ci.draw_line(wick_tip, wick_tip + Vector2(size.x * 0.15, -size.y * 0.12), SMOKE, 1.5)
		ci.draw_line(wick_tip + Vector2(size.x * 0.15, -size.y * 0.12), wick_tip + Vector2(-size.x * 0.05, -size.y * 0.24), SMOKE, 1.5)
		return

	var flame_color := FLAME
	var angle := sin(time * 7.0 + center.x * 0.13) * 0.06
	match diff:
		"flame_blue":
			flame_color = FLAME_BLUE
		"flame_orange":
			flame_color = FLAME_ORANGE
		"flame_tilted":
			angle += deg_to_rad(28.0)
	if diff == "wick_bent":
		angle += deg_to_rad(35.0)
	var flame_base := wick_tip
	ci.draw_circle(flame_base + Vector2.UP * size.y * 0.12, size.x * 1.0, GLOW)
	ci.draw_colored_polygon(_flame_points(flame_base, size.x * 0.42, size.y * 0.3, angle), flame_color)
	ci.draw_colored_polygon(_flame_points(flame_base, size.x * 0.2, size.y * 0.15, angle), FLAME_CORE)


## Teardrop pointing up from `base`, rotated by `angle` around the base.
static func _flame_points(base: Vector2, half_width: float, height: float, angle: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var steps := 14
	for i in steps + 1:
		var t := float(i) / steps
		var y := -t * height
		var x := half_width * sin(t * PI) * (1.0 - t * 0.55)
		points.append(base + Vector2(x, y).rotated(angle))
	for i in range(steps - 1, 0, -1):
		var t := float(i) / steps
		var y := -t * height
		var x := -half_width * sin(t * PI) * (1.0 - t * 0.55)
		points.append(base + Vector2(x, y).rotated(angle))
	return points
