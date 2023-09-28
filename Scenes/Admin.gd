extends Control

var is_gameplay = true
"""
func _ready():
	if UniTime.just_arrived:
		UniTime.just_arrived = false
		get_tree().reload_current_scene()
		get_tree().reload_current_scene()
"""

func _process(delta):
	if !is_gameplay && !$AnimationPlayer.is_playing():
		if Input.is_action_just_pressed("0jump"):
			get_tree().reload_current_scene()
		if Input.is_action_just_pressed("ui_cancel"):
			get_tree().change_scene("res://Scenes/room_MainMenu.tscn")

func animate_player_please() -> void:
	for i in $PlayerScreens.get_children():
		i.get_node("ViewportContainer/Viewport/Game/Player").position = Vector2.ZERO
		i.get_node("ViewportContainer/Viewport/Game/Void").position.y = -1000

func animate_active(active:bool = true) -> void:
	for i in $PlayerScreens.get_children():
		i.active = active
		i.get_node("ViewportContainer/Viewport/Game/Void").active = active
		i.get_node("ViewportContainer/Viewport/Game/Player").active = active
		if !active:
			i.get_node("GUI").rect_position.y = -192

func animate_introduce_ui() -> void:
	for i in $PlayerScreens.get_children():
		var gui = i.get_node("GUI")
		$Tween.interpolate_property(gui,"rect_position:y",-192,0,.5,Tween.TRANS_EXPO,Tween.EASE_OUT)
	$Tween.start()
	
func animate_camera_intro() -> void:
	for i in $PlayerScreens.get_children():
		var camera : Camera2D = i.get_node("ViewportContainer/Viewport/Game/Player/PlayerCamera")
		var offset_orig : Vector2 = camera.offset_orig
		$Tween.interpolate_property(camera,"offset",offset_orig+Vector2.UP*1536,offset_orig,5,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	$Tween.start()
	pass

func animate_slomo():
	UniTime.timescale_sec(3,.2)

func animate_end_screen(enable:bool = false) -> void:
	for i in $PlayerScreens.get_children():
		var end_screen = i.get_node("TextureRect")
		end_screen.visible = enable
		if enable:
			$Tween.interpolate_property(
					end_screen,
					"rect_position:x",
					end_screen.rect_size.x*(-1 if i.player_id == 0 else 1),
					0,
					.25,Tween.TRANS_CIRC,
					Tween.EASE_OUT)
		else:
			end_screen.rect_position.x=end_screen.rect_size.x*(-1 if i.player_id == 0 else 1)
	if enable: $Tween.start()

func get_opponent(MotherObject):
	return $PlayerScreens.get_child(int(!bool(MotherObject.player_id)))

func opponent_platform_halved(MotherObject,time):
	var target = get_opponent(MotherObject)
	target.get_node("ViewportContainer/Viewport/Game").set_width(3)
	
	var timer : Timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = time
	timer.start()
	if !timer.is_stopped():
		yield(timer,"timeout")
	timer.queue_free()
	
	target.get_node("ViewportContainer/Viewport/Game").set_width(4)

func opponent_platform_move(MotherObject,time):
	var target = get_opponent(MotherObject)
	target.get_node("ViewportContainer/Viewport/Game").set_moving(true)
	
	var timer : Timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = time
	timer.start()
	if !timer.is_stopped():
		yield(timer,"timeout")
	timer.queue_free()
	
	target.get_node("ViewportContainer/Viewport/Game").set_moving(false)

func get_opponent_fireball_ui(MotherObject):
	var target = get_opponent(MotherObject)
	return target.get_node("FireballDirection")

func opponent_spawn_fireball(MotherObject,column:int,speed:float,damage:int):
	var target = get_opponent(MotherObject)
	target.get_node("ViewportContainer/Viewport/Game").obj_fireball_spawner.spawn_fireball(column,speed,damage)

func opponent_set_spikes(MotherObject, activate:bool):
	var target = get_opponent(MotherObject)
	target.get_node("ViewportContainer/Viewport/Game").emit_signal("set_spikes", activate)

func white_flag(MotherObject):
	$AnimationPlayer.play("GameOver")
	is_gameplay = false
	var target = get_opponent(MotherObject)
	target.win()

