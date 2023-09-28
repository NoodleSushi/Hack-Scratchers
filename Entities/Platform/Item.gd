extends Area2D
tool
export(float) var speed = 0
export(float) var intensity = 0
export(float) var offset = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var timer = 0

func _process(delta):
	timer = fmod(timer+delta*speed,PI*2)
	$Sprite.position.y = sin(timer)*intensity+offset
