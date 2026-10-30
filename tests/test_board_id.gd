extends "res://tests/test_case.gd"

const BoardId := preload("res://scripts/game/board_id.gd")


func test_roundtrip() -> void:
	for seed in [0, 1, 12345, 31 * 31 * 31 * 31 - 1]:
		for level in 4:
			var decoded := BoardId.decode(BoardId.encode(seed, level))
			check(decoded == {"ok": true, "seed": seed, "level": level}, "%d/%d -> %s" % [seed, level, decoded])


func test_format() -> void:
	check(BoardId.encode(0, 0) == "2222-1", BoardId.encode(0, 0))


func test_normalizes() -> void:
	check(BoardId.decode(" x7k2-3 ").ok, "lowercase with spaces")
	check(BoardId.decode(" x7k2-3 ") == BoardId.decode("X7K23"), "without hyphen")


func test_invalid() -> void:
	for text in ["", "X7K2-9", "X7K2-0", "O0O0-1", "abc", "X7K2-3-4"]:
		check(not BoardId.decode(text).ok, "should reject '%s'" % text)
