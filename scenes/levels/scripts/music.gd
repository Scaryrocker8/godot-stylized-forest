extends AudioStreamPlayer
class_name Music

#? Gonna put the logic for spawning the easter egg here.

#? Surely nobody will find it c:

func _ready() -> void:
    _spawn_easter_egg()

func _on_music_timer_timeout() -> void:
    pitch_scale = randf_range(0.8,1.2)
    play()

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