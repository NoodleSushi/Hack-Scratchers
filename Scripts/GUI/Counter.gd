extends Node2D
tool
var sprite : Texture = preload("res://Sprites/pipboy.png")

export(int) var num = 0 setget set_num

func get_num_index(num,ind) -> int:
	return int(clamp(int(num/pow(10,len(str(num))-ind))%10,0,9))

func set_num(val):
	num = val
	update()

func _draw():
	var rr = $Sprite.region_rect
	var text_size = len(str(num))
	var num_width = rr.size.x/10.0
	for i in range(text_size):
		draw_texture_rect_region(
		sprite,
		Rect2(-num_width*text_size*.5+i*num_width,-rr.size.y*.5,num_width,rr.size.y),
		Rect2(
				rr.position.x+get_num_index(num,i+1)*num_width,
				rr.position.y,
				num_width,
				rr.size.y
			)
		)
