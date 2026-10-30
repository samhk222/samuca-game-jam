extends RefCounted

var failures: Array[String] = []


func check(condition: bool, message: String = "") -> void:
	if not condition:
		failures.append(message)
