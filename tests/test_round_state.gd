extends "res://tests/test_case.gd"

const RoundState := preload("res://scripts/game/round_state.gd")
const BoardGenerator := preload("res://scripts/game/board_generator.gd")

const AREA := Vector2(600, 500)


func _board(level: int = 0) -> Dictionary:
	return {"candles": [Vector2(0.2, 0.5), Vector2(0.8, 0.5)], "unique_index": 1, "diff": "flame_blue", "level": level, "seed": 0}


func _dark(level: int = 0) -> RoundState:
	var state := RoundState.new(_board(level))
	state.light_up()
	state.tick(5.0)
	return state


func test_flow() -> void:
	var state := RoundState.new(_board())
	check(state.phase == RoundState.Phase.WAITING, "starts waiting")
	check(state.light_up(), "light_up ok")
	check(state.phase == RoundState.Phase.LIT, "lit")
	state.tick(1.0)
	check(state.phase == RoundState.Phase.LIT, "still lit at 1.0")
	state.tick(1.5)
	check(state.phase == RoundState.Phase.DARK, "dark after 2.5")
	check(state.elapsed == 0.0, "leftover lit time not counted: %s" % state.elapsed)


func test_timer_only_in_dark() -> void:
	var state := _dark()
	state.tick(2.0)
	check(is_equal_approx(state.elapsed, 2.0), "elapsed %s" % state.elapsed)


func test_hit() -> void:
	var state := _dark()
	check(state.click(Vector2(0.8, 0.5), AREA) == "hit", "hit")
	check(state.phase == RoundState.Phase.DONE, "done")


func test_miss_penalty() -> void:
	var state := _dark()
	check(state.click(Vector2(0.2, 0.5), AREA) == "miss", "miss")
	check(state.penalty == 1.0, "penalty %s" % state.penalty)
	check(state.misses == 1, "misses")
	check(state.phase == RoundState.Phase.DARK, "still dark")


func test_tolerance() -> void:
	var half_width := BoardGenerator.CANDLE_SIZE_NORM.x * AREA.x / 2.0
	var click := Vector2(0.8 + (half_width + 15.0) / AREA.x, 0.5)
	check(_dark(0).click(click, AREA) == "hit", "easy tolerance hit")
	check(_dark(3).click(click, AREA) == "miss", "insane tolerance miss")


func test_ignored_outside_dark() -> void:
	var state := RoundState.new(_board())
	check(state.click(Vector2(0.8, 0.5), AREA) == "ignored", "waiting")
	check(not state.use_powerup("flash"), "powerup while waiting")
	check(state.used.is_empty(), "nothing used")
	state.light_up()
	check(state.click(Vector2(0.2, 0.5), AREA) == "ignored", "lit")
	check(not state.use_powerup("flash"), "powerup while lit")
	state.tick(5.0)
	state.click(Vector2(0.8, 0.5), AREA)
	check(state.click(Vector2(0.2, 0.5), AREA) == "ignored", "done")
	check(state.penalty == 0.0, "no penalty %s" % state.penalty)
	check(not state.light_up(), "cannot relight")


func test_powerup_once() -> void:
	var state := _dark()
	check(state.use_powerup("radar"), "first use")
	check(state.penalty == 4.0, "penalty 4")
	check(not state.use_powerup("radar"), "second use")
	check(state.penalty == 4.0, "still 4")
	check(not state.use_powerup("nope"), "unknown powerup")


func test_total() -> void:
	var state := _dark()
	state.tick(2.0)
	state.click(Vector2(0.2, 0.5), AREA)
	state.use_powerup("flash")
	check(is_equal_approx(state.total_time(), 6.0), "total %s" % state.total_time())


func test_timer_stops_when_done() -> void:
	var state := _dark()
	state.tick(1.0)
	state.click(Vector2(0.8, 0.5), AREA)
	state.tick(3.0)
	check(is_equal_approx(state.elapsed, 1.0), "elapsed frozen %s" % state.elapsed)
