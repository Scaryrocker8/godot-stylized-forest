@tool
extends EditorPlugin

func _enable_plugin() -> void:
	# Input actions here
	add_action("move_left", KEY_A)
	add_action("move_right", KEY_D)
	add_action("move_forward", KEY_W)
	add_action("move_backward", KEY_S)
	add_action("jump", KEY_SPACE)
	add_action("walk", KEY_SHIFT)
	add_action("crouch", KEY_CTRL)
	add_action("pause", KEY_ESCAPE)
	add_action("interact", KEY_E)
	add_action("throw", MOUSE_BUTTON_LEFT)

	ProjectSettings.save()

	print("Jonnie's Simple First Person Plugin: Input actions mapped in Project Settings!")
	print_rich("[color=green]Restarting editor...")

	# NOTE - Unfortunately Godot doesn't have an API to refresh the Input Map Project Settings tab directly.
	# So we need to restart the editor in order for changes to take effect. 
	
	# Wait a couple secs
	await get_tree().create_timer(2.0).timeout
	# Restart editor
	get_editor_interface().restart_editor(true)

func _disable_plugin() -> void:
	remove_action("move_left")
	remove_action("move_right")
	remove_action("move_forward")
	remove_action("move_backward")
	remove_action("jump")
	remove_action("walk")
	remove_action("crouch")
	remove_action("pause")
	remove_action("interact")
	remove_action("throw") 

	ProjectSettings.save()

	#! BUG - When disabling plugin, tree timers stop working. So user will need to restart the editor manually for changes to take effect. 

	print("Jonnie's Simple First Person Plugin: Input actions removed from Project Settings.")
	print_rich("[color=green]Restart editor manually or remove an input action for change to take effect.")

func add_action(action_name: String, input_code: int):
	var event: InputEvent
	
	# Create correct Event type based on the code provided
	if input_code < 10: # Mouse buttons are small integers (1-9)
		var mouse_event := InputEventMouseButton.new()
		mouse_event.button_index = input_code
		event = mouse_event
	else:
		var key_event := InputEventKey.new()
		key_event.physical_keycode = input_code
		event = key_event
	
	var property := "input/" + action_name
	var action_data: Dictionary = ProjectSettings.get_setting(property, { "deadzone": 0.5, "events": [] })
	
	# Check for existing events to avoid duplicates
	var already_has_event := false
	for existing in action_data["events"]:
		if _is_same_input(existing, event):
			already_has_event = true
			break
	
	if not already_has_event:
		action_data["events"].append(event)
		ProjectSettings.set_setting(property, action_data)
		
		# Apply to active InputMap immediately
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		InputMap.action_add_event(action_name, event)

func remove_action(action_name: String):
	var property := "input/" + action_name
	if ProjectSettings.has_setting(property):
		ProjectSettings.set_setting(property, null)
	
	if InputMap.has_action(action_name):
		InputMap.erase_action(action_name)

func _is_same_input(a: InputEvent, b: InputEvent) -> bool:
	if a is InputEventKey and b is InputEventKey:
		return a.physical_keycode == b.physical_keycode
	if a is InputEventMouseButton and b is InputEventMouseButton:
		return a.button_index == b.button_index
	return false