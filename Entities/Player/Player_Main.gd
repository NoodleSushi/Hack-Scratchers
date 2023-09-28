extends KinematicBody2D

const UP := Vector2.UP
const SLOPE_STOP := 64
const UNIT_SIZE := 64


signal item_recieved(platform)
signal hit_by_obstacle(obstacle, damage)


export(int, 0, 4) var player_id setget set_player_id

export(bool) var enable_x_limit : bool = true
export(float) var x_limit : float = 0
var velocity := Vector2.ZERO
#var move_speed := 10 * UNIT_SIZE
var move_speed := 15.3 * UNIT_SIZE
var gravity : float
var max_jump_velocity : float
var min_jump_velocity : float
var is_grounded : bool
export(bool) var invincible : bool = false setget set_invincible
var active : bool = true
var max_jump_height := 3.2*UNIT_SIZE#3 * UNIT_SIZE#2.8 * UNIT_SIZE
var min_jump_height := 1 * UNIT_SIZE
var jump_duration := 0.33

var tex_1 = preload("res://Sprites/animation/the cats/blue-sheet.png")
var tex_2 = preload("res://Sprites/animation/the cats/orange.png")

onready var raycasts = $Raycasts

func effect_whiten(enable:bool) -> void:
	$Sprite.material.set_shader_param("make_white",enable)
	#print("hello "+str(enable))

func set_invincible(set:bool) -> void:
	if set:
		invincible = true
		$Invincibility.play((["DISABLE","ENABLE"])[int(invincible)])
		$InvincibilityTimer.start()
		if !$InvincibilityTimer.is_stopped():
			yield($InvincibilityTimer,"timeout")
		invincible = false
		$Invincibility.play((["DISABLE","ENABLE"])[int(invincible)])
	else:
		if !$InvincibilityTimer.is_stopped():
			$InvincibilityTimer.stop()
	

func set_tinker(is_tinker:bool):
	$StateMachine.set_tinker(is_tinker)

func _ready():
	#$Sprite.get_material().set_shader_param("player_id", player_id)
	#Engine.time_scale = .1
	set_player_id(player_id)
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	$Sprite.material = $Sprite.material.duplicate(true)

func set_player_id(id : int):
	match id:
		0:
			$Sprite.texture = tex_1
		1:
			$Sprite.texture = tex_2
	player_id = id
	
"""
func _physics_process(delta : float) -> void:
	get_input()
	velocity.y += gravity*delta
	
	velocity = move_and_slide(velocity, UP, SLOPE_STOP)
	
	is_grounded = _check_is_grounded()
"""


func _apply_gravity(delta:float) -> void:
	velocity.y += gravity*delta

func _apply_movement() -> void:
	var snap = Vector2.DOWN*8 if !(velocity.y < 0) else Vector2.ZERO
	#velocity = move_and_slide(velocity, UP)
	var prev_y = velocity.y
	if _check_is_grounded() && velocity.y > 0:
		velocity = move_and_slide_with_snap(velocity, Vector2.DOWN*8, UP)#, Vector2() if prev_y < 0 else UP)
	else:
		move_and_slide(velocity, UP)
	is_grounded = _check_is_grounded()
	if enable_x_limit:
		if position.x < -x_limit || position.x > x_limit:
			velocity.x = 0
		position.x = clamp(position.x,-x_limit,x_limit)

func do_hurt():
	velocity.y = max_jump_velocity
	$Audio3.stream = $StateMachine.snd_ouch
	$Audio3.play()

func get_move_direction() -> float:
	return float(int(Input.is_action_pressed(str(player_id)+"move_right")) - int(Input.is_action_pressed(str(player_id)+"move_left")))
	#return Input.get_action_strength(str(player_id)+"move_right") - Input.get_action_strength(str(player_id)+"move_left")

func _handle_move_input(stopper = 1) -> void:
	var move_direction : float = get_move_direction()*stopper
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
	if move_direction != 0:
		$Sprite.flip_h = move_direction > 0

func _get_h_weight() -> float:
	#return 0.3 if is_grounded else 0.15
	return .03 #if is_grounded else .035

func _rotate_to_collision() -> void:
	if is_on_floor():
		for slide in range(min(get_slide_count(),1)):
			var coll = get_slide_collision(slide)
			var ang = coll.normal.angle()
			if abs(ang+PI*.5) > PI*.25: continue
			$Label.set_text(str(rad2deg(abs(ang+PI*.5))))
			#$Sprite.rotation = ang+PI/2.0
			rotation = ang+PI/2.0
			$Position2D.global_position = coll.position

func _rotate_reset() -> void:
	#$Sprite.rotation = 0
	rotation = 0

func _check_is_grounded() -> bool:
	for raycast in raycasts.get_children():
		raycast.self_modulate = ([Color.white,Color.red])[int(raycast.is_colliding())]
		if raycast.is_colliding():
			
			return true
	if is_grounded:
		$JumpTimer.start()
	return false
