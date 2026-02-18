extends CharacterBody3D
class_name Player

const MIN_VIEW_ANGLE: int = -90
const MAX_VIEW_ANGLE: int = 90

@export_group("Player Nodes")
@export var camera: Camera3D
@export var ceiling_detector: RayCast3D
@export var footstep_detector: RayCast3D
@export var interact_detector: RayCast3D
@export var hold_position: Marker3D
@export var collision: CollisionShape3D
@export var head_position: Node3D
@export var landing_animation: Node3D
@export var footstep_audio: AudioStreamPlayer
@export var footstep_user_library: Array[FootstepResource]
@export var footstep_default_sounds: Array[AudioStream]

@export_group("Player Settings")
@export var run_speed: float = 5.0
@export var walk_speed: float = 2.5
@export var jump_velocity: float = 6.0
@export var crouch_speed: float = 1.5
@export var crouch_depth: float = 0.5
@export var out_of_bounds_y_threshold: float = -100.0
@export_subgroup("Advanced Player Settings")
@export var height_lerp_value: float = 0.1
@export var landing_velocity_threshold: float = 2.0
@export var landing_amplitude_value: float = 0.01
@export var min_landing_amplitude: float = 0.0
@export var max_landing_amplitude: float = 0.3

@export_group("Footstep Settings")
@export var footstep_step_distance: float = 2.1
@export var randomize_footstep_pitch: bool = true
@export var randomize_footstep_volume: bool = true
@export var min_footstep_pitch: float = 0.95
@export var max_footstep_pitch: float = 1.05
@export var min_footstep_volume: float = -28.0
@export var max_footstep_volume: float = -23.0
@export var walk_footstep_volume: float = -30.0
@export var crouch_footstep_volume: float = -32.0

@export_group("Interact Settings")
@export var max_carry_weight: float = 30.0	# In kilograms
@export var pull_power: float = 20.0
@export var force_drop_distance: float = 1.0
@export var throw_force: float = 15.0

@export_group("Input Settings")
@export var mouse_sensitivity: float = 0.1
@export_subgroup("Input Map")
@export var move_left: String = "move_left"
@export var move_right: String = "move_right"
@export var move_forward: String = "move_forward"
@export var move_backward: String = "move_backward"
@export var jump: String = "jump"
@export var walk: String = "walk"
@export var crouch: String = "crouch"
@export var pause: String = "pause"
@export var interact: String = "interact"
@export var throw: String = "throw"

@onready var speed: float = run_speed
@onready var original_player_height: float = collision.shape.height

var distance: float
var landing_velocity: float
var footstep_name: String
var held_object: RigidBody3D = null

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_check_input_actions()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		camera.rotation_degrees.x -= event.relative.y * mouse_sensitivity
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, MIN_VIEW_ANGLE, MAX_VIEW_ANGLE)
	
	if event.is_action_pressed(interact):
		if !held_object:
			_pick_up_object()
		else:
			_drop_object()
	
	if event.is_action_pressed(throw) and held_object:
		_throw_object()

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * (delta * 2)
		landing_velocity = -velocity.y
		distance = 0.0

	elif is_on_floor():
		if landing_velocity != 0:
			play_landing_animation(landing_velocity)
			landing_velocity = 0

		if Input.is_action_just_pressed(jump) and is_on_floor():
			velocity.y = jump_velocity
			play_random_footstep_sound()

		if Input.is_action_pressed(walk):
			speed = walk_speed
			footstep_audio.volume_db = walk_footstep_volume

		elif Input.is_action_pressed(crouch):
			speed = crouch_speed
			collision.shape.height = lerp(collision.shape.height, crouch_depth, height_lerp_value)
			footstep_audio.volume_db = crouch_footstep_volume
		else:
			collision.shape.height = lerp(collision.shape.height, original_player_height, height_lerp_value)
		
		if ceiling_detector.is_colliding():
			speed = crouch_speed
			collision.shape.height = crouch_depth
	
	if held_object:
		var target_position: Vector3 = hold_position.global_transform.origin
		var current_position: Vector3 = held_object.global_transform.origin

		var object_direction: Vector3 = target_position - current_position
		var object_distance: float = object_direction.length()

		held_object.linear_velocity = object_direction * pull_power

		if object_distance > force_drop_distance:
			_drop_object()

	var input_dir: Vector2 = Input.get_vector(move_left, move_right, move_forward, move_backward)
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	speed = run_speed

	distance += get_real_velocity().length() * delta

	if distance >= footstep_step_distance:
		distance = 0.0
		if speed > walk_speed:
			play_random_footstep_sound()
	
	if position.y < out_of_bounds_y_threshold:
		position = Vector3.ZERO

	move_and_slide()

func _check_input_actions() -> void:
	var input_actions: Array[String] = [
		move_left,
		move_right,
		move_forward,
		move_backward,
		jump,
		walk,
		crouch,
		pause,
		interact,
		throw
	]

	var check_passed: bool = true

	for action in input_actions.size():
		if !InputMap.has_action(input_actions[action]):
			printerr(input_actions[action] + " action is missing!")
			check_passed = false

	if !check_passed:
		print("Input Map is not set up correctly. Either enable the plugin in Project Settings or add missing actions manually.")
		print("Press F8 to stop currently running project")


func _pick_up_object() -> void:
	var object = interact_detector.get_collider()
	if object is RigidBody3D:
		held_object = object
		held_object.lock_rotation = true
		held_object.gravity_scale = 0.0

func _drop_object() -> void:
	if held_object:
		held_object.lock_rotation = false
		held_object.gravity_scale = 1.0
		held_object = null

func _throw_object() -> void:
	var throw_direction: Vector3 = -camera.global_transform.basis.z

	held_object.lock_rotation = false
	held_object.gravity_scale = 1.0
	held_object.remove_collision_exception_with(self)

	held_object.apply_central_impulse(throw_direction * throw_force)

	held_object = null

func play_landing_animation(landing_velocity: float) -> void:
	if landing_velocity >= landing_velocity_threshold:
		play_random_footstep_sound()

	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	var amplitude: float = clamp(landing_velocity * landing_amplitude_value, min_landing_amplitude, max_landing_amplitude)

	tween.tween_property(landing_animation, "position:y", -amplitude, amplitude)
	tween.tween_property(landing_animation, "position:y", 0, amplitude)

func play_random_footstep_sound() -> void:

	if footstep_detector.is_colliding():

		if footstep_detector.get_collider() is FootstepBody3D:

			footstep_name = footstep_detector.get_collider().footstep_name

			for footstep_resources in footstep_user_library.size():
				match footstep_user_library[footstep_resources].footstep_name:
					footstep_name:
						footstep_audio.stream = footstep_user_library[footstep_resources].footstep_sounds.pick_random()

		elif footstep_default_sounds.size() != 0:
			footstep_audio.stream = footstep_default_sounds.pick_random()

	if randomize_footstep_pitch:
		footstep_audio.pitch_scale = randf_range(min_footstep_pitch, max_footstep_pitch)

	if randomize_footstep_volume:
		footstep_audio.volume_db = randf_range(max_footstep_volume, min_footstep_volume)

	footstep_audio.play()