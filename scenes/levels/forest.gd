@tool
extends Node3D
class_name Forest

const MORNING: float = -170.
const MIDDAY: float = -145.
const DUSK: float = 0.
const NIGHT: float = 90.
const DEFAULT: float = -145.
const RESET: float = 190.

enum Time_Of_Day { MORNING, MIDDAY, DUSK, NIGHT }
var current_time_of_day: Time_Of_Day:
	set(value):
		if current_time_of_day != value:
			current_time_of_day = value
			_update_ambient_audio()

## Set time of day for scene
@export_enum("Default", "Morning", "Midday", "Dusk", "Night") var time_of_day = 0
## Enable or disable the day and night cycle
@export var day_night_cycle: bool = true
## Set length for day and night cycle
@export var day_night_cycle_length: float = 0.005
## View day and night cycle in editor viewport
@export var day_night_cycle_in_editor: bool = false
## Use to disable time_of_day enum
@export var debug: bool = false
@export_group("Forest Nodes")
@export var sun: DirectionalLight3D
@export var music: AudioStreamPlayer
@export_subgroup("Forest Ambience")
@export var ambience_a: AudioStreamPlayer
@export var ambience_b: AudioStreamPlayer
@export var ambient_sounds: Array[AudioStreamWAV]
@export var fade_duration: float = 0.2

@onready var ambient_players: Array[AudioStreamPlayer] = [ambience_a, ambience_b]

var active_ambient_player_index: int

func _ready() -> void:
	_spawn_easter_egg()

func _process(_delta: float) -> void:

	if Engine.is_editor_hint() && !debug:
		if day_night_cycle_in_editor && day_night_cycle:
			sun.rotation_degrees.x += day_night_cycle_length
			_check_for_sun_rotation_reset()
		else:
			change_sun_rotation()
			
	if !Engine.is_editor_hint():
		if day_night_cycle:
			sun.rotation_degrees.x += day_night_cycle_length
			_check_for_sun_rotation_reset()
		
		_check_current_time_of_day()

## If sun's rotation is greater than or equal to RESET value, reset sun back to MORNING position.
## Keeps sun's rotation from moving towards infinity.
func _check_for_sun_rotation_reset() -> void:
	if sun.rotation_degrees.x >= RESET:
		sun.rotation_degrees.x = MORNING

func _check_current_time_of_day() -> void:
	if sun.rotation_degrees.x > MORNING and sun.rotation_degrees.x < MIDDAY:
		current_time_of_day = Time_Of_Day.MORNING

	elif sun.rotation_degrees.x > MIDDAY and sun.rotation_degrees.x < DUSK:
		current_time_of_day = Time_Of_Day.MIDDAY

	elif sun.rotation_degrees.x > DUSK and sun.rotation_degrees.x < NIGHT:
		current_time_of_day = Time_Of_Day.DUSK
	
	elif sun.rotation_degrees.x > NIGHT:
		current_time_of_day = Time_Of_Day.NIGHT

func change_sun_rotation() -> void:
	match time_of_day:
		0:
			sun.rotation_degrees.x = DEFAULT
		1:
			sun.rotation_degrees.x = MORNING
		2:
			sun.rotation_degrees.x = MIDDAY
		3:
			sun.rotation_degrees.x = DUSK
		4:
			sun.rotation_degrees.x = NIGHT

## Smoothly fade between different ambiences.
func _update_ambient_audio() -> void:
	var old_player: AudioStreamPlayer = ambient_players[active_ambient_player_index]
	active_ambient_player_index = (active_ambient_player_index + 1) % 2
	var new_player: AudioStreamPlayer = ambient_players[active_ambient_player_index]

	new_player.stream = ambient_sounds[current_time_of_day]
	#new_player.volume_db = -80.0
	new_player.play()

	var tween: Tween = create_tween().set_parallel(true)

	tween.tween_property(old_player, "volume_db", -10.0, fade_duration)
	tween.tween_property(new_player, "volume_db", -4.0, fade_duration)

	tween.chain().tween_callback(old_player.stop)

func _on_music_timer_timeout() -> void:
	music.pitch_scale = randf_range(0.8,1.2)
	music.play()

func _spawn_easter_egg() -> void:
	var easter_egg: PackedScene = preload("res://assets/glb/easter_egg/easter_egg.glb")
	var easter_egg_instance: Node3D = easter_egg.instantiate()
	add_child(easter_egg_instance)
	
	easter_egg_instance.position.x = -122.
	easter_egg_instance.position.y = 1.2
	easter_egg_instance.position.z = 120.
	easter_egg_instance.rotation_degrees.y = 48.
