extends Control

const BoardId := preload("res://scripts/game/board_id.gd")
const BoardGenerator := preload("res://scripts/game/board_generator.gd")
const Difficulty := preload("res://scripts/game/difficulty.gd")
const Records := preload("res://scripts/game/records.gd")
const RoundState := preload("res://scripts/game/round_state.gd")

var records := Records.new()
var current_seed := 0
var current_level := 0
var current_id := ""

@onready var play_area: Control = $Margin/Columns/Center/PlayArea
@onready var timer_label: Label = $Margin/Columns/Center/TimerLabel
@onready var status_label: Label = $Margin/Columns/Center/StatusLabel
@onready var level_label: Label = $Margin/Columns/Left/LevelLabel
@onready var level_slider: HSlider = $Margin/Columns/Left/LevelSlider
@onready var id_edit: LineEdit = $Margin/Columns/Left/IdRow/IdEdit
@onready var id_error: Label = $Margin/Columns/Left/IdError
@onready var record_label: Label = $Margin/Columns/Left/RecordLabel
@onready var powerup_buttons := {
	"flash": $Margin/Columns/Right/FlashButton,
	"lantern": $Margin/Columns/Right/LanternButton,
	"radar": $Margin/Columns/Right/RadarButton,
}


func _ready() -> void:
	randomize()
	$Margin/Columns/Left/RestartButton.pressed.connect(func(): _load_board(current_seed, current_level))
	$Margin/Columns/Left/NewButton.pressed.connect(func(): _load_board(BoardId.random_seed(), current_level))
	$Margin/Columns/Left/LoadButton.pressed.connect(_load_typed_id)
	$Margin/Columns/Left/IdRow/CopyButton.pressed.connect(func(): DisplayServer.clipboard_set(current_id))
	id_edit.text_submitted.connect(func(_text): _load_typed_id())
	level_slider.value_changed.connect(func(value): _load_board(current_seed, int(value)))
	for id in powerup_buttons:
		powerup_buttons[id].pressed.connect(play_area.activate_powerup.bind(id))
	play_area.state_changed.connect(_on_state_changed)
	play_area.miss_clicked.connect(func(): status_label.text = "Errou! +1 s")
	play_area.finished.connect(_on_finished)
	_load_board(BoardId.random_seed(), 0)


func _process(_delta: float) -> void:
	var state: RoundState = play_area.state
	if state == null:
		return
	var text := _format_time(state.total_time())
	if state.penalty > 0.0:
		text += "  (penalidade +%s)" % _format_time(state.penalty)
	timer_label.text = text
	for id in powerup_buttons:
		powerup_buttons[id].disabled = state.phase != RoundState.Phase.DARK or state.used.has(id)


## Starting a board always aborts the current round without saving.
func _load_board(seed: int, level: int) -> void:
	current_seed = seed
	current_level = level
	current_id = BoardId.encode(seed, level)
	id_edit.text = current_id
	id_error.visible = false
	level_slider.set_value_no_signal(level)
	level_label.text = "Dificuldade: %s" % Difficulty.LEVEL_NAMES[level]
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
			status_label.text = "Clique na área preta para acender."
		RoundState.Phase.LIT:
			status_label.text = "Memorize a vela diferente!"
		RoundState.Phase.DARK:
			status_label.text = "Clique onde estava a vela diferente."


func _on_finished(total: float, misses: int) -> void:
	var text := "Achou! %s" % _format_time(total)
	if misses > 0:
		text += " (%d %s)" % [misses, "erro" if misses == 1 else "erros"]
	if records.submit(current_id, total):
		text += " — Novo recorde!"
	status_label.text = text
	_update_record()


func _update_record() -> void:
	var best := records.best(current_id)
	record_label.text = "Recorde: —" if best < 0.0 else "Recorde: %s" % _format_time(best)


func _format_time(seconds: float) -> String:
	return ("%.2f s" % seconds).replace(".", ",")
