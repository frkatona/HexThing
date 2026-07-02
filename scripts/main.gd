extends Node3D

@onready var level_label: Label = %LevelLabel
@onready var score_label: Label = %ScoreLabel

var current_level := 1
var score := 0


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return

	match event.keycode:
		KEY_A:
			current_level += 1
			level_label.text = str(current_level)
			get_viewport().set_input_as_handled()
		KEY_S:
			score += 1
			score_label.text = str(score)
			get_viewport().set_input_as_handled()
