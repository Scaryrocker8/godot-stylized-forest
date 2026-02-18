extends DirectionalLight3D
class_name Sun

func _process(_delta: float) -> void:
	# Keep slowly rotating the sun.
	rotation_degrees.x += 0.005
