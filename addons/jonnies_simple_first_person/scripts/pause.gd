extends Control
class_name Pause

@export var player: Player
@export var reticle: Control
@export var title: Label
@export var hint_player: AnimationPlayer

var is_paused: bool = false

func _ready() -> void:
	title.text = ProjectSettings.get("application/config/name")
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(player.pause):
		if !is_paused:
			_pause()
		else:
			_resume()

func _pause() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	visible = true
	reticle.visible = false
	get_tree().paused = true
	is_paused = true

func _resume() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	visible = false
	reticle.visible = true
	get_tree().paused = false
	is_paused = false

func _on_resume_pressed() -> void:
	_resume()

func _on_hide_menu_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	visible = false
	hint_player.play("hint")

func _on_quit_pressed() -> void:
	get_tree().quit()