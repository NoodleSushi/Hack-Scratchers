extends StateMachine

onready var JumpTimer := $"../JumpTimer"
var state_names = ["idle","run","jump","fall","tinker"]
onready var parent := get_parent()
onready var Animator : AnimationPlayer = $"../AnimationPlayer"

var snd_jump = load("res://Audio/snd_jump.wav")
var snd_ouch = load("res://Audio/snd_ouch.wav")

func _ready() -> void:
	for state_element in state_names:
		add_state(state_element)
	call_deferred("set_state", states.idle)

func _state_logic(delta : float) -> void:
	if parent.active:
		parent._handle_move_input(int(state != states.tinker))
	parent._apply_gravity(delta)
	parent._apply_movement()
	#print(parent.velocity.y)
	#if ([states.run,states.idle]).has(state) :
	#	parent._rotate_to_collision()
	


func set_tinker(is_tinker:bool):
	if is_tinker:
		set_state(states.tinker)
		#if parent._check_is_grounded(): parent.velocity.x = 0
	else:
		set_state(states.idle)

func _unhandled_input(event : InputEvent) -> void:
	if state == states.tinker || !parent.active: return
	if event.is_action_pressed(str(parent.player_id)+"jump") && (parent.velocity.y >= 0) && (parent.is_grounded || !parent.is_grounded && !JumpTimer.is_stopped()):
		JumpTimer.stop()
		parent.velocity.y = parent.max_jump_velocity
		$"../Audio2".stream = snd_jump
		$"../Audio2".play()
		set_state(states.jump)
		#parent.get_node("Dust").restart()
		#parent.get_node("Dust").emitting = true
		
		

func _is_running() -> bool:
	##return abs(parent.velocity.x) > 300 | parent.move_speed/2.0
	return abs(parent.velocity.x) > parent.move_speed/6.0

func _get_transition(delta : float):
	match state:
		states.idle:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
			elif _is_running():
				return states.run
		states.run:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					return states.fall
				elif parent.velocity.y == 0:
					return states.idle
			elif !_is_running():
				return states.idle
		states.jump:
			if parent.is_on_floor():
				return states.idle
			elif parent.velocity.y >= 0:
				if parent.is_on_floor():
					if _is_running():
						return states.run
					else:
						return states.idle
				else:
					return states.fall
		states.fall:
			if parent.is_on_floor():
				if _is_running():
					return states.run
				else:
					return states.idle
			elif parent.velocity.y < 0:
				return states.jump
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			Animator.play("Idle")
		states.run:
			Animator.play("Run")
		states.jump:
			Animator.play("Jump_rise")
		states.fall:
			Animator.play("Jump_fall")
		states.tinker:
			Animator.play("Tinker_start")
		#states.fall:
			#Animator.play('fall')
		
	#$"../Label".set_text(state_names[state])

func _exit_state(old_state, new_state):
	if old_state == states.fall:
		parent.get_node("Dust").emit()
