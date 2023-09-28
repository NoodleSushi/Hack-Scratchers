extends Node2D
tool
export(int,0,8) var lives := 8 setget set_lives
var sprite : Texture = preload("res://Sprites/health.png")
var rand : float = 0

func set_lives(val):
	lives = val
	if has_node("Tween"):
		$Tween.interpolate_property(self,"rand",8,0,.5,Tween.TRANS_EXPO,Tween.EASE_OUT)
		$Tween.start()

var timer = 0

func _process(delta):
	timer = fmod(timer+delta*8,PI*2)
	update()

func _draw():
	for i in range(4):
		var rand_pos = Vector2(randf()-.5,randf()-.5)*4*rand
		var index = 0
		if lives == i*2+1:
			index = 1
		elif lives >= i*2+2:
			index = 2
		draw_texture_rect_region(
			sprite,
			Rect2((Vector2.RIGHT*48*i+Vector2.UP*sin(timer+i)*4+rand_pos).round(),Vector2.ONE*48),
			Rect2(index*48,0,48,48)
		)
