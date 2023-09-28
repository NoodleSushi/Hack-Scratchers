extends Node2D

var img = load("res://Sprites/matrix.png")
var display = []

func _ready():
	for i in range(32):
		display.append(randi()%32)

func _draw():
	position.y += 16
	var index = 0
	display.remove(31)
	display.push_front(randi()%32)
	for i in display:
		var opacity = float(-index+32)/32
		draw_texture_rect_region(
				img,
				Rect2(-8,-8-index*16,16,16),
				Rect2(i*8,0,8,8),
				Color.white-Color(0,0,0,1-opacity))
		index += 1


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # Replace with function body.
