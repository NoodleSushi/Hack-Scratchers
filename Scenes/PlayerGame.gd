extends Node2D

var scn_platform = preload("res://Entities/Platform/Platformincase.tscn")
var scn_player = preload("res://Entities/Player/Player.tscn")

var obj_player : KinematicBody2D
var obj_camera := preload("res://Entities/Player/PlayerCamera.tscn").instance()
var obj_bodies := Node.new()
var obj_void := preload("res://Entities/Void/Void.tscn").instance()
var obj_fireball_spawner := preload("res://Entities/Fireball/FireballSpawner.tscn").instance()

var view_size : Vector2 = Vector2.ZERO

onready var Mother = $"../../.."


var level_list := [ [4,1,4], [4,4,4,1], [5,2], [2,2,2], [2,5], [4,1], [5,5], [2,2], [2], [5]]
var level_index := 0
var level_pointer := -2
var level_scroll := 0

var width : int = 4 setget set_width
var moving : bool = false setget set_moving
var spawn_spikes : bool = false

func set_spawn_spikes(enable : bool):
	spawn_spikes = enable
	for i in obj_bodies.get_children():
		if enable && randi()%2 == 0: i.set_spikes_enable(true)
		if !enable: i.set_spikes_enable(false)

func set_width(val:int):
	width = val
	for i in obj_bodies.get_children():
		i.set_width(val)

func set_moving(val:bool):
	moving = val
	if moving:
		for i in obj_bodies.get_children():
			i.set_move_type(2-int(i.origin.x))
	else:
		for i in obj_bodies.get_children():
			i.set_move_type(0)

class RandomAreaGenerator:
	var base_x_num : int = 16#10#16
	var tile_size : int = 32
	var ymax : int = (base_x_num*9.0)/4.0
	var y_change : float = ymax*tile_size
	var room_list = [[],[],[]]
	
	signal area_advanced(y_change)
	
	
	func test(bodies):
		for object in room_list[1]+room_list[2]:
			
			object.global_position.y += 1
			#object.get_node("Platform").sync_to_physics = false
			#object.get_node("Platform").move_and_slide(Vector2.DOWN*1)
			#object.get_node("Platform").sync_to_physics = true
	
	func advance_area():
		for object in room_list[0]:
			object.queue_free()
		for object in room_list[1]+room_list[2]:
			object.change_pos(Vector2.DOWN*y_change)
		room_list[0] = room_list[1]
		room_list[1] = room_list[2]
		room_list[2] = []
		emit_signal("area_advanced",y_change)
	
	func obj_to_room(object:Object,room_id : int = 2):
		room_list[room_id].append(object)

var RAG = RandomAreaGenerator.new()

func _ready():
	randomize()
	#Connect signal that shoots when level advances
	RAG.connect("area_advanced",self,"_on_RAG_area_advanced")
	RAG.connect("area_advanced",obj_camera,"_on_RAG_area_advanced")
	#Connect signal that shoots viewport changes & update viewport
	get_viewport().connect("size_changed",self,"_on_Viewport_size_changed")
	_on_Viewport_size_changed()
	
	add_child(obj_bodies)
	
	#Generate First Level
	level_generate(1,false)
	#Instance Player
	instantiate_player()
	
	#Instance Camera
	obj_player.add_child(obj_camera)
	obj_camera.current = true
	obj_camera.position = Vector2.ZERO
	obj_camera.process_mode = Camera2D.CAMERA2D_PROCESS_PHYSICS
	
	#Instance Base Plate
	var base_plat = scn_platform.instance()
	obj_bodies.add_child(base_plat)
	RAG.obj_to_room(base_plat,1)
	#base_plat.normalize()
	base_plat.name = "faggotory"
	base_plat.width = RAG.base_x_num
	base_plat.position = Vector2.ZERO
	base_plat.origin = Vector2.DOWN
	base_plat.free_item()
	
	#Instance Void
	add_child(obj_void)
	
	#Instance Fireball Spawner
	add_child(obj_fireball_spawner)

func _process(delta):
	if obj_player.position.y <= -RAG.y_change && Mother.active:
		RAG.advance_area()
	#RAG.test(obj_bodies)
	pass
func _on_RAG_area_advanced(y_change):
	for i in obj_fireball_spawner.get_children():
		i.get_node("Area2D").set_monitoring(false)
	obj_void.position.y += RAG.y_change
	obj_player.position.y += RAG.y_change
	for i in obj_fireball_spawner.get_children():
		i.position.y += RAG.y_change
		i.get_node("Area2D").set_monitoring(true)
	$BGSOLID/Node2D.position.y += 1152
	$BGSOLID/Node2D.position.y = fmod($BGSOLID/Node2D.position.y,2304)
	$BGTHING/Node2D.position.y += 1152
	$BGTHING/Node2D.position.y = fmod($BGTHING/Node2D.position.y,1536)
	level_generate(RAG.ymax)

func _on_Viewport_size_changed():
	"""
	var vps = get_viewport().size
	obj_camera.zoom = Vector2.ONE*((RAG.base_x_num*16)/(vps.x/4.0))*2
	view_size = vps
	"""
	var vps = get_viewport().size
	var vps_x = stepify(vps.x/2.0,2)
	var vps_y = stepify(vps.y/2.0,2)
	obj_camera.zoom = Vector2.ONE*(720.0/vps_y)
	#obj_camera.zoom = Vector2.ONE*((RAG.base_x_num*RAG.tile_size)/vps_x)
	#obj_camera.zoom = Vector2.ONE*ceil((RAG.base_x_num*RAG.tile_size)/vps.x)
	view_size = vps

func instantiate_player():
	obj_player = scn_player.instance()
	add_child(obj_player)
	obj_player.position = Vector2.ZERO
	obj_player.z_index = 1
	obj_player.player_id = Mother.player_id
	obj_player.connect("item_recieved",Mother,"_on_Player_item_recieved")
	obj_player.connect("hit_by_obstacle",Mother,"_on_Player_hit_by_obstacle")

func get_level() -> int:
	level_pointer += 1
	if level_pointer == -1 || level_pointer >= level_list[level_index].size():
		level_pointer = 0
		level_index = randi()%level_list[level_index].size()
	return level_list[level_index][level_pointer]

func level_generate(limit:int,spawn_stuff : bool = true) -> void:

	for y in range(limit,RAG.ymax*2):
		level_scroll = (level_scroll+1)%5
		if level_scroll != 0: continue
		var level : int = get_level()
		for i in range(3):
			if (level >> (2-i)) & 1 != 1: continue
			var new_plat = scn_platform.instance()
			obj_bodies.add_child(new_plat)
			RAG.obj_to_room(new_plat,1+int(y>=RAG.ymax))
			new_plat.width = width
			new_plat.set_pos(Vector2( (i-1)*RAG.tile_size*RAG.base_x_num*0.5 , -y*RAG.tile_size ))
			#new_plat.global_position.x = (i-1)*RAG.tile_size*RAG.base_x_num*0.5
			#new_plat.global_position.y = -y*RAG.tile_size
			new_plat.origin = Vector2(1-i,1)
			new_plat.is_one_way = true
			Mother.connect("spike_changed",new_plat,"on_Mother_spike_changed")
			if moving: new_plat.move_type = i+1
			if !spawn_stuff: new_plat.free_item()
	pass
