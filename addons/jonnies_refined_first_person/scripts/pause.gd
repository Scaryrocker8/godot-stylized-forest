extends Control
class_name Pause

@export_group("Pause Nodes")
@export var player: Player
@export var reticle: Control
@export var title: Label
@export var resume_button: Button
@export var depth_of_field_button: Button
@export var glow_type_button: Button
@export var quit_button: Button
@export var pause_player: AnimationPlayer
@export var hide_player: AnimationPlayer
@export var glow_presets: Array[Resource]

var is_paused: bool = false
var depth_of_field: bool = false
var changed_glow: bool = false

var time_of_day: int

@onready var world_environment: WorldEnvironment = get_tree().root.get_node("Forest").get_node("WorldEnvironment")

func _ready() -> void:
	title.text = ProjectSettings.get("application/config/name")
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(player.keyboard_inputs.pause):
		if !is_paused:
			_pause()
		else:
			_resume()

	if event.is_action_pressed(player.keyboard_inputs.jump):
		if is_paused and resume_button.has_focus():
			_resume()
		elif is_paused and quit_button.has_focus():
			get_tree().quit()

func _pause() -> void:
	pause_player.play("pause")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.process_mode = Node.PROCESS_MODE_DISABLED	
	resume_button.grab_focus()
	is_paused = true

func _resume() -> void:
	# wait at least a couple frames before resuming so player doesn't instantly jump
	await get_tree().create_timer(0.02).timeout		

	pause_player.play("resume")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.process_mode = Node.PROCESS_MODE_INHERIT
	is_paused = false

func _hide_cursor() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_resume_pressed() -> void:
	_resume()

func _on_hide_menu_pressed() -> void:
	hide_player.play("hide_menu")

func _on_glow_type_pressed() -> void:
	if !changed_glow:
		world_environment.environment = glow_presets[1]
		glow_type_button.text = "Glow Type: Softlight"
		changed_glow = true
	else:
		world_environment.environment = glow_presets[0]
		glow_type_button.text = "Glow Type: Screen"
		changed_glow = false

func _on_depth_of_field_pressed() -> void:
	if !depth_of_field:
		player.camera.attributes.set("dof_blur_far_enabled", true)
		player.camera.attributes.set("dof_blur_near_enabled", true)
		depth_of_field_button.text = "Depth of Field: On"
		depth_of_field = true
	else:
		player.camera.attributes.set("dof_blur_far_enabled", false)
		player.camera.attributes.set("dof_blur_near_enabled", false)
		depth_of_field_button.text = "Depth of Field: Off"
		depth_of_field = false		

func _on_quit_pressed() -> void:
	get_tree().quit()
