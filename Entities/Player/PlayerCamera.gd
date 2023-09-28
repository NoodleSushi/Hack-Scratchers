extends Camera2D

var pos : Vector2 = Vector2()
var orig_zoom = Vector2.ONE
var latest_y : float = 0
var is_following : bool = true
#var rand_add : Vector2 = Vector2()
onready var offset_orig = offset
onready var parent = get_parent()

func do_shake():
	$Tween.interpolate_method(self, "randomize_off", 32, 0, .75, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Tween.start()

func randomize_off(amp:float):
	offset = offset_orig+Vector2(rand_range(-1,1),rand_range(-1,1))*amp

func cam_update() -> void:
	global_position = pos
	force_update_scroll()

func _physics_process(delta):
	if parent.global_position.y < latest_y:
		latest_y = parent.global_position.y
	#pos.y = lerp(pos.y,latest_y,delta*2)
	if is_following:
		pos.y = lerp(pos.y,parent.global_position.y,delta*2)
	cam_update()

func _on_RAG_area_advanced(y_change):
	pos.y += y_change
	latest_y += y_change
	cam_update()

