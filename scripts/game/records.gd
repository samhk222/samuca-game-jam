extends RefCounted
## Best time per board ID, stored locally (IndexedDB on Web via user://).

var _path: String
var _best := {}


func _init(path: String = "user://records.json") -> void:
	_path = path
	_load()


## Returns -1.0 when there is no record for this ID.
func best(id: String) -> float:
	return float(_best.get(id, -1.0))


## Saves the time if it beats the stored one; returns true for a new record.
func submit(id: String, time: float) -> bool:
	var previous := best(id)
	if previous >= 0.0 and time >= previous:
		return false
	_best[id] = time
	_save()
	return true


func _load() -> void:
	if not FileAccess.file_exists(_path):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(_path))
	if data is Dictionary:
		for id in data:
			if data[id] is float or data[id] is int:
				_best[id] = float(data[id])


func _save() -> void:
	var file := FileAccess.open(_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_best))
