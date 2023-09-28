extends Node2D

var sprite : Texture = preload("res://Sprites/pipboy.png")
tool

export(int) var num := 0 setget num_set
export(bool) var blink = false setget set_blink
var last_num = 0
var jump = 0.0

func num_set(val):
	last_num = num
	num = val
	if has_node("Tween"):
		$Tween.interpolate_property(self,"jump",1.0,0.0,.25,Tween.TRANS_CUBIC,Tween.EASE_OUT)
		$Tween.start()
	update()

func _process(delta):
	if has_node("Tween") && $Tween.is_active():
		update()

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

func get_num_index(num,ind) -> int:
	return int(clamp(int(num/pow(10,3-ind))%10,0,9))

func _draw():
	for i in range(4):
		var is_changed = int(get_num_index(num,i) != get_num_index(last_num,i))
		draw_texture_rect_region(
			sprite,
			Rect2(i*8,6*jump*is_changed,8,16),
			Rect2(get_num_index(num,i)*8,112,8,16),
			Color(1,1,1,1-jump*is_changed)
		)
	pass


func _on_Tween_tween_completed(object, key):
	update()
