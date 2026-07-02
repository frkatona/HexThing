extends Control

const GAME_SCENE := "res://scenes/Main.tscn"
const START_SOUND: AudioStream = preload("res://assets/audio/sfx/press-start.mp3")
const GEM_FRAMES: Array[Texture2D] = [
	preload("res://assets/sprites/gemSprite-1.png"),
	preload("res://assets/sprites/gemSprite-2.png"),
	preload("res://assets/sprites/gemSprite-3.png"),
	preload("res://assets/sprites/gemSprite-4.png"),
]

@onready var hero_gem: TextureRect = %HeroGem
@onready var start_button: Button = %StartButton
@onready var fade: ColorRect = %Fade

var _animation_time := 0.0
var _frame_index := 0
var _is_transitioning := false


func _ready() -> void:
	start_button.grab_focus()


func _process(delta: float) -> void:
	_animation_time += delta
	var next_frame := int(_animation_time * 7.0) % GEM_FRAMES.size()
	if next_frame != _frame_index:
		_frame_index = next_frame
		hero_gem.texture = GEM_FRAMES[_frame_index]

	var pulse := 1.0 + sin(_animation_time * 2.2) * 0.025
	hero_gem.scale = Vector2.ONE * pulse
	hero_gem.rotation = sin(_animation_time * 1.35) * 0.018


func _unhandled_input(event: InputEvent) -> void:
	if _is_transitioning:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_quit_pressed()


func _on_start_pressed() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	start_button.disabled = true
	_play_start_sound()
	fade.visible = true
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.3)
	await tween.finished
	get_tree().change_scene_to_file(GAME_SCENE)


func _play_start_sound() -> void:
	# Keep this player at the tree root so the sound is not cut off by
	# changing away from the start-menu scene.
	var sound_player := AudioStreamPlayer.new()
	sound_player.stream = START_SOUND
	sound_player.bus = &"SFX"
	sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(sound_player)
	sound_player.finished.connect(sound_player.queue_free)
	sound_player.play()


func _on_quit_pressed() -> void:
	get_tree().quit()
