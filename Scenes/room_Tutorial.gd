extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var adder = int(Input.is_action_pressed("0move_right")) - int(Input.is_action_pressed("0move_left"))
	print(int(adder*delta*1000))
	$ScrollContainer.scroll_horizontal += int(adder*delta*500)
	if Input.is_action_just_pressed("0jump"):
		get_tree().change_scene("res://Scenes/room_GamePlayDev.tscn")
