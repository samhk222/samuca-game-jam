extends RefCounted
## Builds a board deterministically from (seed, level). Positions are normalized
## (0-1) candle centers so the same ID looks the same at any play-area size.

const Difficulty := preload("res://scripts/game/difficulty.gd")

## Candle body size as a fraction of the play area. Shared with drawing and hit-tests.
const CANDLE_SIZE_NORM := Vector2(0.035, 0.12)
const MARGIN := Vector2(0.04, 0.09)
const SPACING := 1.3
const MAX_ATTEMPTS := 300


static func generate(seed: int, level: int) -> Dictionary:
	var settings := Difficulty.get_level(level)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed * 4 + level
	var count: int = settings.count
	var candles := _scatter(rng, count)
	if candles.size() < count:
		candles = _grid(rng, count)
	var diffs: Array = settings.diffs
	return {
		"candles": candles,
		"unique_index": rng.randi_range(0, count - 1),
		"diff": diffs[rng.randi_range(0, diffs.size() - 1)],
		"level": level,
		"seed": seed,
	}


## Rejection sampling: natural-looking layout; returns fewer than count if it runs out of room.
static func _scatter(rng: RandomNumberGenerator, count: int) -> Array[Vector2]:
	var candles: Array[Vector2] = []
	var gap := CANDLE_SIZE_NORM * SPACING
	for i in count:
		var placed := false
		for attempt in MAX_ATTEMPTS:
			var p := Vector2(rng.randf_range(MARGIN.x, 1.0 - MARGIN.x), rng.randf_range(MARGIN.y, 1.0 - MARGIN.y))
			var free := true
			for other in candles:
				if absf(p.x - other.x) < gap.x and absf(p.y - other.y) < gap.y:
					free = false
					break
			if free:
				candles.append(p)
				placed = true
				break
		if not placed:
			return candles
	return candles


## Fallback that always fits: shuffled grid cells with a little jitter.
static func _grid(rng: RandomNumberGenerator, count: int) -> Array[Vector2]:
	var area := Vector2.ONE - MARGIN * 2.0 + CANDLE_SIZE_NORM
	var cols := int(area.x / (CANDLE_SIZE_NORM.x * 1.1))
	var rows := int(area.y / (CANDLE_SIZE_NORM.y * 1.1))
	var cell := area / Vector2(cols, rows)
	var cells: Array[Vector2] = []
	for row in rows:
		for col in cols:
			cells.append(Vector2(col, row))
	for i in range(cells.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := cells[i]
		cells[i] = cells[j]
		cells[j] = tmp
	var origin := MARGIN - CANDLE_SIZE_NORM / 2.0
	var slack := cell - CANDLE_SIZE_NORM
	var candles: Array[Vector2] = []
	for i in count:
		var jitter := Vector2(rng.randf() * slack.x, rng.randf() * slack.y)
		candles.append(origin + cells[i] * cell + CANDLE_SIZE_NORM / 2.0 + jitter)
	return candles
