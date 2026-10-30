extends RefCounted
## All difficulty tuning lives here. Tweak after playtesting.

const LEVEL_NAMES := ["Easy", "Medium", "Hard", "Insane"]

## Seconds added for each click that misses the unique candle.
const MISS_PENALTY := 1.0

## count: candles on the board; lit_time: seconds the board stays visible;
## diffs: ways the unique candle may differ (the board seed picks one).
const LEVELS: Array[Dictionary] = [
	{"count": 8, "lit_time": 2.0, "diffs": ["flame_blue"]},
	{"count": 20, "lit_time": 1.2, "diffs": ["flame_orange", "flame_tilted"]},
	{"count": 40, "lit_time": 0.45, "diffs": ["no_wick", "wax_drip"]},
	{"count": 70, "lit_time": 0.3, "diffs": ["wick_bent"]},
]


static func get_level(level: int) -> Dictionary:
	return LEVELS[clampi(level, 0, LEVELS.size() - 1)]
