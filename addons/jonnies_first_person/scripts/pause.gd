extends Control
class_name Pause

@export_group("Pause Nodes")
@export var player: Player
@export var reticle: Control
@export var title: Label
@export_subgroup("Buttons")
@export var resume_button: Button
@export var hide_menu_button: Button
@export var day_night_cycle_button: Button
@export var time_of_day_button: Button
@export var toggle_reticle_button: Button
@export var depth_of_field_button: Button
@export var glow_type_button: Button
@export var quit_button: Button
@export_subgroup("Animation Players")
@export var pause_player: AnimationPlayer
@export var hide_player: AnimationPlayer
@export_subgroup("Glow Presets")
@export var glow_presets: Array[Resource]

var is_paused: bool = false
var reticle_visible: bool = false
var depth_of_field: bool = false
var changed_glow: bool = false

@onready var forest: Forest = get_tree().root.get_node("Forest")
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

	if event.is_action_pressed(player.keyboard_inputs.jump) and is_paused:

		var focused_button: Control = get_viewport().gui_get_focus_owner()

		if focused_button is Button:
			focused_button.pressed.emit()

func _process(_delta: float) -> void:
	_update_time_of_day()

#region Helper Funcs

func _pause() -> void:

	player.process_mode = Node.PROCESS_MODE_DISABLED

	await get_tree().process_frame

	resume_button.grab_focus()
	pause_player.play("pause")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	is_paused = true

func _resume() -> void:

	await get_tree().create_timer(0.02).timeout

	player.process_mode = Node.PROCESS_MODE_INHERIT

	pause_player.play("resume")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	is_paused = false

func _hide_cursor() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _hide_menu() -> void:
	hide_player.play("hide_menu")

func _toggle_day_night_cycle() -> void:
	if forest.day_night_cycle:
		forest.day_night_cycle = false
		day_night_cycle_button.text = "Day Night Cycle: Off"
	else:
		forest.day_night_cycle = true
		day_night_cycle_button.text = "Day Night Cycle: On"

func _change_time_of_day() -> void:

	match forest.current_time_of_day:
		forest.Time_Of_Day.MORNING:
			forest.current_time_of_day = forest.Time_Of_Day.MIDDAY
			forest.time_of_day = 2
			forest.change_sun_rotation()
		forest.Time_Of_Day.MIDDAY:
			forest.current_time_of_day = forest.Time_Of_Day.DUSK
			forest.time_of_day = 3
			forest.change_sun_rotation()
		forest.Time_Of_Day.DUSK:
			forest.current_time_of_day = forest.Time_Of_Day.NIGHT
			forest.time_of_day = 4
			forest.change_sun_rotation()
		forest.Time_Of_Day.NIGHT:
			forest.current_time_of_day = forest.Time_Of_Day.MORNING
			forest.time_of_day = 1
			forest.change_sun_rotation()

func _update_time_of_day() -> void:

	match forest.current_time_of_day:
		forest.Time_Of_Day.MORNING:
			time_of_day_button.text = "Time of Day: Morning"
		forest.Time_Of_Day.MIDDAY:
			time_of_day_button.text = "Time of Day: Midday"
		forest.Time_Of_Day.DUSK:
			time_of_day_button.text = "Time of Day: Dusk"
		forest.Time_Of_Day.NIGHT:
			time_of_day_button.text = "Time of Day: Night"

func _change_depth_of_field() -> void:
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

func _change_glow_preset() -> void:
	if !changed_glow:
		world_environment.environment = glow_presets[1]
		glow_type_button.text = "Glow Type: Softlight"
		changed_glow = true
	else:
		world_environment.environment = glow_presets[0]
		glow_type_button.text = "Glow Type: Screen"
		changed_glow = false

func _toggle_reticle() -> void:
	if reticle_visible:
		player.enable_reticle = false
		toggle_reticle_button.text = "Reticle: Off"
		reticle_visible = false
	else:
		player.enable_reticle = true
		toggle_reticle_button.text = "Reticle: On"
		reticle_visible = true

#endregion

#region Buttons

func _on_resume_pressed() -> void:
	_resume()

func _on_hide_menu_pressed() -> void:
	_hide_menu()

func _on_day_night_cycle_pressed() -> void:
	_toggle_day_night_cycle()

func _on_time_of_day_pressed() -> void:
	_change_time_of_day()

func _on_depth_of_field_pressed() -> void:
	_change_depth_of_field()	

func _on_glow_type_pressed() -> void:
	_change_glow_preset()

func _on_toggle_reticle_pressed() -> void:
	_toggle_reticle()

func _on_quit_pressed() -> void:
	get_tree().quit()

#endregion
