extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
onready var orig_offy = offset.y
var tim = 0
func _process(delta):
	tim = fmod(tim+delta,PI*2)
	offset.y = orig_offy+sin(tim)*16
