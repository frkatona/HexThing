extends CanvasLayer

const MUSIC_BUS := &"Music"
const PAUSED_MUSIC_VOLUME_DB := -2.0

@onready var pause_overlay: Control = %PauseOverlay
@onready var continue_button: Button = %ContinueButton
@onready var pause_sound: AudioStreamPlayer = %PauseSound
@onready var continue_sound: AudioStreamPlayer = %ContinueSound

var _music_bus_index := -1
var _low_pass_effect_index := -1
var _previous_music_volume_db := 0.0
var _previous_low_pass_enabled := false
var _is_paused := false


func _ready() -> void:
	_music_bus_index = AudioServer.get_bus_index(MUSIC_BUS)
	_low_pass_effect_index = _find_low_pass_effect()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("ui_cancel"):
		print(AudioServer.get_bus_volume_db(2))
		if _is_paused:
			_unpause_game()
		else:
			_pause_game()
		get_viewport().set_input_as_handled()


func _pause_game() -> void:
	_capture_music_state()
	if _music_bus_index >= 0:
		AudioServer.set_bus_volume_db(_music_bus_index, PAUSED_MUSIC_VOLUME_DB)
	if _low_pass_effect_index >= 0:
		AudioServer.set_bus_effect_enabled(_music_bus_index, _low_pass_effect_index, true)

	_is_paused = true
	pause_overlay.show()
	get_tree().paused = true
	pause_sound.play()
	continue_button.grab_focus()


func _unpause_game() -> void:
	pause_overlay.hide()
	continue_sound.play()
	_restore_music_state()
	_is_paused = false
	get_tree().paused = false


func _capture_music_state() -> void:
	if _music_bus_index < 0:
		return
	_previous_music_volume_db = AudioServer.get_bus_volume_db(_music_bus_index)
	if _low_pass_effect_index >= 0:
		_previous_low_pass_enabled = AudioServer.is_bus_effect_enabled(
			_music_bus_index,
			_low_pass_effect_index
		)


func _restore_music_state() -> void:
	if _music_bus_index < 0:
		return
	AudioServer.set_bus_volume_db(_music_bus_index, _previous_music_volume_db)
	if _low_pass_effect_index >= 0:
		AudioServer.set_bus_effect_enabled(
			_music_bus_index,
			_low_pass_effect_index,
			_previous_low_pass_enabled
		)


func _find_low_pass_effect() -> int:
	if _music_bus_index < 0:
		return -1
	for effect_index in AudioServer.get_bus_effect_count(_music_bus_index):
		if AudioServer.get_bus_effect(_music_bus_index, effect_index) is AudioEffectLowPassFilter:
			return effect_index
	return -1


func _on_continue_pressed() -> void:
	_unpause_game()


func _on_restart_pressed() -> void:
	_restore_music_state()
	_is_paused = false
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	_restore_music_state()
	_is_paused = false
	get_tree().paused = false
	get_tree().quit()


func _exit_tree() -> void:
	if _is_paused:
		_restore_music_state()
		get_tree().paused = false
