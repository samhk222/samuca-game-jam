extends RefCounted
## Power-ups: each usable once per round, only while the board is dark.
## duration: seconds the effect lasts; penalty: seconds added to the final time.

const ALL: Array[Dictionary] = [
	{"id": "flash", "name": "Flash", "duration": 0.5, "penalty": 3.0},
	{"id": "lantern", "name": "Flashlight", "duration": 4.0, "penalty": 5.0},
	{"id": "radar", "name": "Radar", "duration": 3.0, "penalty": 4.0},
]


static func by_id(id: String) -> Dictionary:
	for powerup in ALL:
		if powerup.id == id:
			return powerup
	return {}
