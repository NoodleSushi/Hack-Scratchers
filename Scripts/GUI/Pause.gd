extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	visible = false

func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
		var new_pause_state = get_tree().paused
		visible = new_pause_state
		if new_pause_state:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
