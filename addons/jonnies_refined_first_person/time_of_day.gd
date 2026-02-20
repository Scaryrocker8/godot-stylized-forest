extends Button
class_name TimeOfDay

# Const rotations of Sun
const MORNING: float = -170.0
const MIDDAY: float = -90.0
const DUSK: float = 0.0
const NIGHT: float = 90.0

enum TIME_OF_DAY{ 
	MORNING, 
	MIDDAY, 
	DUSK, 
	NIGHT 
	}
var current_time: TIME_OF_DAY

@export var sun: Sun
