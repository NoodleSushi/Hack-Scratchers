extends Sprite
tool
export(Vector2) var original_position = Vector2(0,0)
export(int,0,3) var level = 0 setget set_level
export(bool) var blink = false setget set_blink
var last_level = 0
func set_level(val : int):
	var different = level != val
	frame = val
	last_level = level
	level = val
	if !has_node("Tween") || !different: return
	$Tween.interpolate_method(
			self,
			"change_x",
			-4,
			0,
			.8,
			Tween.TRANS_BACK,
			Tween.EASE_OUT
	)
	$Tween.interpolate_method(
			self,
			"blink",
			0,
			6,
			1,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN
	)
	$Tween.start()

func change_x(val):
	position = (original_position+Vector2.RIGHT*val)

func blink(val:int):
	frame = level if val%2 == 0 else last_level

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
	
	#var new_frame = int(level+4*fmod(floor(animation_index),2))
	#print(new_frame)
	#frame = new_frame
	#assert(frame == new_frame)
	
