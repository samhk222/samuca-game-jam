extends RefCounted
## One round: waiting -> lit (memorize) -> dark (timer runs, click to find) -> done.

const Difficulty := preload("res://scripts/game/difficulty.gd")
const Powerups := preload("res://scripts/game/powerups.gd")
const BoardGenerator := preload("res://scripts/game/board_generator.gd")

enum Phase { WAITING, LIT, DARK, DONE }

var board: Dictionary
var phase: Phase = Phase.WAITING
## Seconds spent in the dark searching (excludes penalties).
var elapsed := 0.0
var penalty := 0.0
var misses := 0
## Power-up ids already used this round.
var used := {}

var _settings: Dictionary
var _lit_left := 0.0


func _init(round_board: Dictionary) -> void:
	board = round_board
	_settings = Difficulty.get_level(board.level)


func light_up() -> bool:
	if phase != Phase.WAITING:
		return false
	phase = Phase.LIT
	_lit_left = _settings.lit_time
	return true


func tick(delta: float) -> void:
	match phase:
		Phase.LIT:
			_lit_left -= delta
			if _lit_left <= 0.0:
				phase = Phase.DARK
		Phase.DARK:
			elapsed += delta


## norm_pos is the click in normalized (0-1) play-area coordinates.
func click(norm_pos: Vector2, area_size: Vector2) -> String:
	if phase != Phase.DARK:
		return "ignored"
	if is_on_unique(norm_pos, area_size):
		phase = Phase.DONE
		return "hit"
	misses += 1
	penalty += Difficulty.MISS_PENALTY
	return "miss"


func is_on_unique(norm_pos: Vector2, area_size: Vector2) -> bool:
	var center: Vector2 = board.candles[board.unique_index] * area_size
	var half := BoardGenerator.CANDLE_SIZE_NORM * area_size / 2.0 + Vector2.ONE * float(_settings.hit_tolerance)
	var click_px := norm_pos * area_size
	var offset := (click_px - center).abs()
	if offset.x > half.x or offset.y > half.y:
		return false
	# Tolerance must never turn a click on a neighbouring candle into a hit.
	var own_distance := click_px.distance_to(center)
	for candle in board.candles:
		if (candle * area_size).distance_to(click_px) < own_distance:
			return false
	return true


func use_powerup(id: String) -> bool:
	var powerup := Powerups.by_id(id)
	if phase != Phase.DARK or powerup.is_empty() or used.has(id):
		return false
	used[id] = true
	penalty += powerup.penalty
	return true


func total_time() -> float:
	return elapsed + penalty
