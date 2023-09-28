extends Control

var wait = false
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass # Replace with function body

func _process(delta):
	if wait || $AnimationPlayer.is_playing(): return
	var sec : float = 2
	var check = true
	for i in range(2):
		var spr = get_node("Center/blue-sheet"+str(i))
		var is_press = Input.is_action_pressed(str(i)+"jump")
		spr.material.set_shader_param("trans",int(!is_press))
		spr.get_node("Sprite").frame = int(is_press)
		check = check && is_press
	if check: 
		wait = true
		$AnimationPlayer.play("Ready")

func proceed():
	UniTime.just_arrived = true
	get_tree().change_scene("res://Scenes/room_Tutorial.tscn")
	#get_tree().reload_current_scene()


func _on_Button_pressed():
	get_tree().quit()
