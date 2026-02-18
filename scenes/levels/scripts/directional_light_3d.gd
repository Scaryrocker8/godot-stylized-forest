extends DirectionalLight3D

func _process(_delta: float) -> void:
    # Keep slowly rotating sun
    rotation_degrees.x += 0.005