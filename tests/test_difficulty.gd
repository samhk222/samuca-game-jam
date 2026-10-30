extends "res://tests/test_case.gd"

const Difficulty := preload("res://scripts/game/difficulty.gd")
const Powerups := preload("res://scripts/game/powerups.gd")


func test_four_levels() -> void:
	check(Difficulty.LEVELS.size() == 4, "expected 4 levels")


func test_counts() -> void:
	var counts := Difficulty.LEVELS.map(func(l): return l.count)
	var lit := Difficulty.LEVELS.map(func(l): return l.lit_time)
	check(counts == [8, 20, 40, 70], "counts %s" % [counts])
	check(lit == [2.0, 1.2, 0.45, 0.3], "lit %s" % [lit])


func test_clamp() -> void:
	check(Difficulty.get_level(-1) == Difficulty.LEVELS[0], "clamp low")
	check(Difficulty.get_level(9) == Difficulty.LEVELS[3], "clamp high")


func test_powerups() -> void:
	check(Powerups.ALL.size() == 3, "3 powerups")
	check(Powerups.by_id("flash").penalty == 3.0, "flash")
	check(Powerups.by_id("lantern").penalty == 5.0, "lantern")
	check(Powerups.by_id("radar").penalty == 4.0, "radar")
