extends Control

const BoardId := preload("res://scripts/game/board_id.gd")
const BoardGenerator := preload("res://scripts/game/board_generator.gd")
const Difficulty := preload("res://scripts/game/difficulty.gd")
const Records := preload("res://scripts/game/records.gd")
const RoundState := preload("res://scripts/game/round_state.gd")
const UiTheme := preload("res://scripts/ui_theme.gd")

var records := Records.new()
var current_seed := 0
var current_level := 0
var current_id := ""

@onready var play_area: Control = %PlayArea
@onready var timer_label: Label = %TimerLabel
@onready var penalty_label: Label = %PenaltyLabel
@onready var status_label: Label = %StatusLabel
@onready var level_buttons: GridContainer = %LevelButtons
@onready var id_edit: LineEdit = %IdEdit
@onready var id_error: Label = %IdError
@onready var record_label: Label = %RecordLabel
@onready var powerup_buttons := {
	"flash": %FlashButton,
	"lantern": %LanternButton,
	"radar": %RadarButton,
}


func _ready() -> void:
	randomize()
	theme = UiTheme.build()
	%RestartButton.pressed.connect(func(): _load_board(current_seed, current_level))
	%NewButton.pressed.connect(func(): _load_board(BoardId.random_seed(), current_level))
	%LoadButton.pressed.connect(_load_typed_id)
	%CopyButton.pressed.connect(func(): DisplayServer.clipboard_set(current_id))
	id_edit.text_submitted.connect(func(_text): _load_typed_id())
	var level_group := ButtonGroup.new()
	for level in Difficulty.LEVEL_NAMES.size():
		var button := Button.new()
		button.text = Difficulty.LEVEL_NAMES[level]
		button.toggle_mode = true
		button.button_group = level_group
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func(): _load_board(current_seed, level))
		level_buttons.add_child(button)
	for id in powerup_buttons:
		powerup_buttons[id].pressed.connect(play_area.activate_powerup.bind(id))
	play_area.state_changed.connect(_on_state_changed)
	play_area.miss_clicked.connect(func(): status_label.text = "Missed! +1 s")
	play_area.finished.connect(_on_finished)
	_load_board(BoardId.random_seed(), 0)


func _process(_delta: float) -> void:
	var state: RoundState = play_area.state
	if state == null:
		return
	timer_label.text = _format_time(state.total_time())
	penalty_label.text = "+%d s penalty" % roundi(state.penalty) if state.penalty > 0.0 else ""
	for id in powerup_buttons:
		powerup_buttons[id].disabled = state.phase != RoundState.Phase.DARK or state.used.has(id)


## Starting a board always aborts the current round without saving.
func _load_board(seed: int, level: int) -> void:
	current_seed = seed
	current_level = level
	current_id = BoardId.encode(seed, level)
	id_edit.text = current_id
	id_error.visible = false
	for button: Button in level_buttons.get_children():
		button.set_pressed_no_signal(button.get_index() == level)
	_update_record()
	play_area.start_round(BoardGenerator.generate(seed, level))


func _load_typed_id() -> void:
	var decoded := BoardId.decode(id_edit.text)
	if not decoded.ok:
		id_error.visible = true
		return
	_load_board(decoded.seed, decoded.level)


func _on_state_changed() -> void:
	var state: RoundState = play_area.state
	match state.phase:
		RoundState.Phase.WAITING:
			status_label.text = "Click the dark area to light it up."
		RoundState.Phase.LIT:
			status_label.text = "Memorize the odd candle!"
		RoundState.Phase.DARK:
			status_label.text = "Click where the odd candle was."


func _on_finished(total: float, misses: int) -> void:
	var text := "Found it! %s" % _format_time(total)
	if misses > 0:
		text += " (%d %s)" % [misses, "miss" if misses == 1 else "misses"]
	if records.submit(current_id, total):
		text += " — New best!"
	status_label.text = text
	_update_record()


func _update_record() -> void:
	var best := records.best(current_id)
	record_label.text = "—" if best < 0.0 else _format_time(best)


func _format_time(seconds: float) -> String:
	var millis := roundi(seconds * 1000.0)
	return "%02d:%02d.%03d" % [millis / 60000, (millis / 1000) % 60, millis % 1000]
