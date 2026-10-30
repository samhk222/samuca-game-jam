extends Control
## The central board: draws candles, darkness and power-up effects, and turns
## clicks into round actions.

signal finished(total: float, misses: int)
signal miss_clicked
signal state_changed

const RoundState := preload("res://scripts/game/round_state.gd")
const BoardGenerator := preload("res://scripts/game/board_generator.gd")
const CandleDrawer := preload("res://scripts/game/candle_drawer.gd")
const Powerups := preload("res://scripts/game/powerups.gd")

const LANTERN_RADIUS := 70.0
const MISS_MARK_TIME := 0.4
const BACKGROUND := Color(0.02, 0.02, 0.03)
const LIT_BACKGROUND := Color(0.1, 0.07, 0.05)

var state: RoundState
## Power-up id -> seconds of effect left.
var _effects := {}
## Each miss mark: {pos: Vector2, left: float}.
var _miss_marks: Array[Dictionary] = []
var _time := 0.0


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP


func start_round(board: Dictionary) -> void:
	state = RoundState.new(board)
	_effects.clear()
	_miss_marks.clear()
	state_changed.emit()
	queue_redraw()


func activate_powerup(id: String) -> bool:
	if state == null or not state.use_powerup(id):
		return false
	_effects[id] = Powerups.by_id(id).duration
	state_changed.emit()
	return true


func _process(delta: float) -> void:
	_time += delta
	if state == null:
		return
	var before := state.phase
	state.tick(delta)
	for id in _effects.keys():
		_effects[id] -= delta
		if _effects[id] <= 0.0:
			_effects.erase(id)
	for mark in _miss_marks:
		mark.left -= delta
	_miss_marks = _miss_marks.filter(func(mark): return mark.left > 0.0)
	if state.phase != before:
		state_changed.emit()
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if state == null:
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	accept_event()
	if state.phase == RoundState.Phase.WAITING:
		state.light_up()
		state_changed.emit()
		return
	match state.click(event.position / size, size):
		"miss":
			_miss_marks.append({"pos": event.position, "left": MISS_MARK_TIME})
			miss_clicked.emit()
		"hit":
			_effects.clear()
			finished.emit(state.total_time(), state.misses)
			state_changed.emit()


func _draw() -> void:
	if state == null:
		draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND)
		return
	var phase := state.phase
	var show_all := phase == RoundState.Phase.LIT or phase == RoundState.Phase.DONE or _effects.has("flash")
	draw_rect(Rect2(Vector2.ZERO, size), LIT_BACKGROUND if show_all else BACKGROUND)

	if phase == RoundState.Phase.WAITING:
		_draw_centered_text("Clique para acender", 22, Color(0.85, 0.85, 0.9))
		return

	var mouse := get_local_mouse_position()
	var lantern := _effects.has("lantern")
	if lantern and not show_all:
		draw_circle(mouse, LANTERN_RADIUS, Color(1.0, 0.85, 0.5, 0.08))
		draw_arc(mouse, LANTERN_RADIUS, 0.0, TAU, 48, Color(1.0, 0.85, 0.5, 0.25), 1.5)

	var candle_size := BoardGenerator.CANDLE_SIZE_NORM * size
	var candles: Array = state.board.candles
	for i in candles.size():
		var center: Vector2 = candles[i] * size
		if not show_all and not (lantern and center.distance_to(mouse) <= LANTERN_RADIUS):
			continue
		var diff: String = state.board.diff if i == state.board.unique_index else ""
		CandleDrawer.draw(self, center, candle_size, diff, _time + i)

	if phase == RoundState.Phase.DONE:
		var unique_center: Vector2 = candles[state.board.unique_index] * size
		draw_arc(unique_center, candle_size.y * 0.75, 0.0, TAU, 48, Color(0.4, 1.0, 0.5), 3.0)

	if _effects.has("radar") and phase == RoundState.Phase.DARK:
		var unique_center: Vector2 = candles[state.board.unique_index] * size
		var closeness := clampf(1.0 - mouse.distance_to(unique_center) / (size.length() * 0.45), 0.0, 1.0)
		var color := Color(0.3, 0.55, 1.0).lerp(Color(1.0, 0.2, 0.15), closeness)
		draw_arc(mouse, 14.0, 0.0, TAU, 32, color, 4.0)
		draw_circle(mouse, 5.0, color)

	for mark in _miss_marks:
		var alpha: float = mark.left / MISS_MARK_TIME
		var p: Vector2 = mark.pos
		var c := Color(1.0, 0.25, 0.2, alpha)
		draw_line(p + Vector2(-7, -7), p + Vector2(7, 7), c, 3.0)
		draw_line(p + Vector2(-7, 7), p + Vector2(7, -7), c, 3.0)


func _draw_centered_text(text: String, font_size: int, color: Color) -> void:
	var font := get_theme_default_font()
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	draw_string(font, Vector2((size.x - text_size.x) / 2.0, (size.y + text_size.y / 2.0) / 2.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
