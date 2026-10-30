extends "res://tests/test_case.gd"

const BoardGenerator := preload("res://scripts/game/board_generator.gd")


func test_deterministic() -> void:
	var a := BoardGenerator.generate(42, 2)
	var b := BoardGenerator.generate(42, 2)
	check(a.candles == b.candles, "candles differ")
	check(a.unique_index == b.unique_index, "unique differs")
	check(a.diff == b.diff, "diff differs")


func test_seed_changes_board() -> void:
	check(BoardGenerator.generate(42, 1).candles != BoardGenerator.generate(43, 1).candles, "same board")


func test_counts_per_level() -> void:
	for level in 4:
		var size: int = BoardGenerator.generate(7, level).candles.size()
		check(size == [8, 20, 40, 70][level], "level %d has %d" % [level, size])


func test_no_overlap_insane() -> void:
	var s := BoardGenerator.CANDLE_SIZE_NORM
	for seed in 20:
		var candles: Array = BoardGenerator.generate(seed, 3).candles
		for i in candles.size():
			for j in range(i + 1, candles.size()):
				var d: Vector2 = candles[i] - candles[j]
				check(absf(d.x) >= s.x or absf(d.y) >= s.y, "seed %d: %d overlaps %d" % [seed, i, j])


func test_inside_bounds() -> void:
	for seed in 10:
		for level in 4:
			for p in BoardGenerator.generate(seed, level).candles:
				check(p.x >= 0.03 and p.x <= 0.97 and p.y >= 0.08 and p.y <= 0.92, "out of bounds %s" % p)


func test_diff_from_level() -> void:
	for seed in 10:
		check(BoardGenerator.generate(seed, 0).diff == "flame_blue", "level 0 diff")
		check(BoardGenerator.generate(seed, 1).diff in ["flame_orange", "flame_tilted"], "level 1 diff")


func test_unique_index_in_range() -> void:
	for seed in 20:
		var board := BoardGenerator.generate(seed, seed % 4)
		check(board.unique_index >= 0 and board.unique_index < board.candles.size(), "index range")


func test_grid_fallback_fits() -> void:
	var s := BoardGenerator.CANDLE_SIZE_NORM
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var candles: Array = BoardGenerator._grid(rng, 70)
	check(candles.size() == 70, "grid count %d" % candles.size())
	for i in candles.size():
		var p: Vector2 = candles[i]
		check(p.x >= 0.03 and p.x <= 0.97 and p.y >= 0.08 and p.y <= 0.92, "grid out of bounds %s" % p)
		for j in range(i + 1, candles.size()):
			var d: Vector2 = p - candles[j]
			check(absf(d.x) >= s.x or absf(d.y) >= s.y, "grid overlap %d/%d" % [i, j])
