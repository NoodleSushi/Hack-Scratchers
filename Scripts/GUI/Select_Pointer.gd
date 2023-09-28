extends Sprite

var orig_pos = Vector2(-24,-56)

func change(new_frame:int,adder:int):
	frame = new_frame
	$Tween.interpolate_method(
			self,
			"change_x",
			adder*8,
			0,
			1,
			Tween.TRANS_ELASTIC,
			Tween.EASE_OUT
	)
	$Tween.start()
	pass

func change_x(val):
	position = (orig_pos+Vector2.RIGHT*val).round()
