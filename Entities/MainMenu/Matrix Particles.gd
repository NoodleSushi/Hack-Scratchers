extends Control

var obj_particle = load("res://Entities/MainMenu/MatrixParticle.tscn")
var timer = 0
var timer2 = 0
func _process(delta):
	timer += delta
	timer2 += delta
	while timer > 0.08:
		timer -= 0.08
		for child in get_children():
			child.update()
	
	while timer2 > .2:
		timer2 -= .2
		var new_particle = obj_particle.instance()
		add_child(new_particle)
		new_particle.position = Vector2(stepify(rand_range(0,rect_size.x),16),8)
