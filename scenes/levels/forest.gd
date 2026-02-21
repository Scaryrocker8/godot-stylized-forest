@tool
extends Node3D
class_name Forest

const DEFAULT: float = -145.
const MORNING: float = -170.
const MIDDAY: float = -90.
const DUSK: float = 0.
const NIGHT: float = 90.

@export_enum("Default", "Morning", "Midday", "Dusk", "Night") var time_of_day = 0
@export var day_night_cycle: bool = true
@export var cycle_in_editor: bool = false
@export_group("Forest Nodes")
@export var sun: DirectionalLight3D
@export var music: AudioStreamPlayer

func _ready() -> void:
    _spawn_easter_egg()

func _process(_delta: float) -> void:

    if Engine.is_editor_hint():
        if cycle_in_editor && day_night_cycle:
            sun.rotation_degrees.x += 0.005
        else:
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
            
    if !Engine.is_editor_hint():
        if day_night_cycle:
            sun.rotation_degrees.x += 0.005

func _on_music_timer_timeout() -> void:
    music.pitch_scale = randf_range(0.8,1.2)
    music.play()

func _spawn_easter_egg() -> void:
	# Spawn Easter Egg
    var easter_egg: PackedScene = preload("res://assets/glb/easter_egg/easter_egg.glb")
    var easter_egg_instance: Node3D = easter_egg.instantiate()
    add_child(easter_egg_instance)
	
	# Move easter egg
    easter_egg_instance.position.x = -122.
    easter_egg_instance.position.y = 1.2
    easter_egg_instance.position.z = 120.
    easter_egg_instance.rotation_degrees.y = 48.
