extends RefCounted
## Shareable board IDs like "X7K2-3": four seed characters plus the level (1-4).
## The alphabet skips 0/O/1/I/L so IDs are easy to read aloud.

const ALPHABET := "23456789ABCDEFGHJKMNPQRSTUVWXYZ"
const SEED_LENGTH := 4
const MAX_SEED := 31 * 31 * 31 * 31


static func encode(seed: int, level: int) -> String:
	var text := ""
	var value := posmod(seed, MAX_SEED)
	for i in SEED_LENGTH:
		text = ALPHABET[value % ALPHABET.length()] + text
		value /= ALPHABET.length()
	return "%s-%d" % [text, level + 1]


static func decode(text: String) -> Dictionary:
	var invalid := {"ok": false, "seed": 0, "level": 0}
	var clean := text.strip_edges().to_upper().replace("-", "")
	if clean.length() != SEED_LENGTH + 1 or text.count("-") > 1:
		return invalid
	var seed := 0
	for i in SEED_LENGTH:
		var digit := ALPHABET.find(clean[i])
		if digit < 0:
			return invalid
		seed = seed * ALPHABET.length() + digit
	var level_char := clean[SEED_LENGTH]
	if not level_char in ["1", "2", "3", "4"]:
		return invalid
	return {"ok": true, "seed": seed, "level": int(level_char) - 1}


static func random_seed() -> int:
	return randi() % MAX_SEED
