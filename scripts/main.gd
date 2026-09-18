extends Control

var count: int = 0

@onready var counter_label: Label = $Center/Content/Counter


func _on_count_button_pressed() -> void:
	count += 1
	counter_label.text = "Count: %d" % count
