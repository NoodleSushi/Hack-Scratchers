extends Node2D
tool
var sprite : Texture = preload("res://Sprites/pipboy.png")

export(int) var cost = 0 setget set_cost
export(bool) var blink = false setget set_blink
func get_num_index(num,ind) -> int:
	return int(clamp(int(num/pow(10,len(str(num))-ind))%10,0,9))

func set_blink(val):
	if !has_node("Tween") || !val: return
	$Tween.interpolate_method(
		self,
		"_blink_no_money_animation",
		0,
		12,
		1,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN)
	$Tween.start()

func _blink_no_money_animation(animation_index:float):
	#animaton_index: 0 -> 6
	self_modulate = Color.white-Color(0,1,1,0)*fmod(floor(animation_index),2)

func set_cost(val):
	cost = val
	update()

func _draw():
	for i in range(len(str(cost))+1):
		if i == len(str(cost)):
			draw_texture_rect_region(
			sprite,
			Rect2(i*4,0,5,8),
			Rect2(160,176,5,8))
		else:
			draw_texture_rect_region(
			sprite,
			Rect2(i*4,0,4,8),
			Rect2(120+get_num_index(cost,i+1)*4,176,4,8))
