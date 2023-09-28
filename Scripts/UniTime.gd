extends Node

var pi2 = 0

signal temp_pause(state)

var just_arrived = false

func _ready():
	set_pause_mode(Node.PAUSE_MODE_PROCESS)

func _physics_process(delta):
	pi2 = fmod(pi2+delta,PI*2)
	pass

func pause_sec(time):
	emit_signal("temp_pause",true)
	get_tree().paused = true
	
	var timer : Timer = Timer.new()
	add_child(timer)
	timer.set_pause_mode(Node.PAUSE_MODE_PROCESS)
	timer.one_shot = true
	timer.wait_time = time
	timer.start()
	if !timer.is_stopped():
		yield(timer,"timeout")
	timer.queue_free()
	
	get_tree().paused = false
	emit_signal("temp_pause",false)

func timescale_sec(duration:float,time_scale:float):
	Engine.time_scale = time_scale
	print(Engine.time_scale)
	var timer : Timer = Timer.new()
	add_child(timer)
	timer.set_pause_mode(Node.PAUSE_MODE_PROCESS)
	timer.one_shot = true
	timer.wait_time = duration*time_scale
	timer.start()
	if !timer.is_stopped():
		yield(timer,"timeout")
	timer.queue_free()
	print(Engine.time_scale)
	Engine.time_scale = 1
