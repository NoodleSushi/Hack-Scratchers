extends Node

var scn_fireball = preload("res://Entities/Fireball/Fireball.tscn")

onready var Parent = get_parent()
onready var camera = (Parent.obj_camera as Camera2D)

func get_y() -> float:
	return camera.global_position.y+camera.offset.y+Parent.view_size.y*camera.zoom.y/2.0

func spawn_fireball(column:int,speed:float,damage:int) -> void:
	#0 - left
	#1 - center
	#2 - right
	var new_fireball = scn_fireball.instance()
	add_child(new_fireball)
	new_fireball.global_position.x = (column-1)*(512.0/3.0)
	new_fireball.global_position.y = get_y()
	new_fireball.speed = speed
	new_fireball.damage = damage
