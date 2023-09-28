extends CPUParticles2D

var pos = Vector2()

func emit():
	pos = get_parent().global_position
	restart()
	emitting = true

func _physics_process(delta):
	global_position = pos
