extends Line2D
enum STATE {NULL,DISABLED,ENABLED}
onready var Parent = get_parent()
var y_scan_size = 240
var state = STATE.NULL
onready var camera = (Parent.obj_camera as Camera2D)
onready var player = Parent.obj_player

var active = true
func get_y() -> float:
	return camera.global_position.y+camera.offset.y+Parent.view_size.y*camera.zoom.y/2.0

var player_y_step = 0
var player_y_real = 0
var search_time = 5
var speed = 96
var back_limit = 192
func _ready():
	visible = true
	global_position.y = get_y() + back_limit

func pystep() -> float:
	return stepify(player.global_position.y,32)

func py() -> float:
	return player.global_position.y

func _process(delta):
	if !active:
		global_position.y = get_y() + back_limit
	if !active: return
	if global_position.y - get_y() > back_limit:
		global_position.y = get_y() + back_limit
		pass
	global_position.y -= delta*speed
	
	"""
	match state:
		STATE.NULL:
			$Timer.start(search_time)
			player_y_real = py()
			player_y_step = pystep() 
			state = STATE.DISABLED
		STATE.DISABLED:
			if player_y_real-py() >= y_scan_size:
				player_y_real = py()
				$Timer.start(search_time)
			if $Timer.is_stopped() || pystep() > player_y_step:
				state = STATE.ENABLED
				visible = true
				global_position.y = get_y()
				$Timer.stop()
		STATE.ENABLED:
			global_position.y -= delta*speed
			if !$VisibilityNotifier2D.is_on_screen():
				$Timer.start(search_time)
				visible = false
				player_y_real = py()
				state = STATE.DISABLED
	player_y_step = pystep()
	"""
	#$ColorRect.material.set_shader_param("add",position.y/camera.zoom.y)


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		body.emit_signal("hit_by_obstacle",self,0)
