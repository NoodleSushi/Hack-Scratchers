extends Control

signal spike_changed(enable)

export(int,0,1) var player_id = 0


enum STATE {BROWSE,UPGRADE,FIREBALL_AIM}
enum TIMER {PLATFORM,FIREBALL,FIREBALL_SHOOT,SPIKE}
var state = STATE.BROWSE
var browse_selection = ITEM.PLATFORM
var active = false
enum ITEM {COIN,PLATFORM,SPIKE,FIREBALL,NONE = 0}
var coins = 0
var held_upgrade = ITEM.NONE
var virus_lvl = [0,0,0]
var lives = 8
var tinker = false
onready var Admin = $"../.."
var latest_object_collided = null
#SOUNDS
var snd_pickup_box = AudioPlug.new_sfx(self,"res://Audio/snd_pickup_box.wav")
var snd_virus_level_up = AudioPlug.new_sfx(self,"res://Audio/snd_virus_level_up.wav")
var snd_coin = AudioPlug.new_sfx(self,"res://Audio/snd_coin.wav")
var snd_virus_browse = AudioPlug.new_sfx(self,"res://Audio/snd_virus_browse.wav")

var fireball_column : int = 1

func deplete_lives(damage:int):
	lives -= damage
	lives = clamp(lives,0,8)
	$GUI/Interface/LifeCounter.set_lives(lives)
	

func _ready():
	update_GUI()

func get_upgrade_cost():
	return pow(2,virus_lvl[held_upgrade-1]+1)

func get_upgrade_timer():
	return floor(2+virus_lvl[held_upgrade-1]*1.5)

func set_tinker(val:bool):
	tinker = val
	$ViewportContainer/Viewport/Game/Player.set_tinker(val)

var press_timer = .0
var utility_press_stopper = false
var timer = [0,0,0,0]

func _process(delta):
	if !active: return
	$ViewportContainer/Viewport/Game.obj_player.effect_whiten(false)
	for i in range(timer.size()):
		timer[i] = 0 if timer[i]-delta <= 0 || timer[i] == 0 else timer[i] - delta
		#if timer[i] > 0: print(timer[i])
	
	var utility_press = Input.is_action_pressed(str(player_id)+"utility")
	var utility_released = Input.is_action_just_released(str(player_id)+"utility")
	match state:
		STATE.BROWSE:
			#DEFAULTS
			$GUI/Interface/Loading.visible = false
			#CHECK IF UPGRADE BOX IS HELD
			if held_upgrade > 0:
				press_timer = press_timer+delta if utility_press else 0
				if press_timer >= .25:
					#SET STATE TO STATE.UPGRADE WHEN COINS IS >= UPGRADE COST
					if coins >= get_upgrade_cost():
						$snd_loading.play()
						press_timer = 0
						set_tinker(true)
						state = STATE.UPGRADE
						utility_press_stopper = true
						update_GUI()
						Input.start_joy_vibration(player_id,.25,.25,get_upgrade_timer())
						return
					else:
						$GUI/Interface/Indicators/Upgrade/Cost.blink = true
						$GUI/Interface/Indicators/CoinCounter.blink = true
						press_timer = 0
						utility_press_stopper = true
						return
			
			##CHANGE POINTER
			var left_press = Input.is_action_pressed(str(player_id)+"browse_left")
			var right_press = Input.is_action_pressed(str(player_id)+"browse_right")
			$GUI/Interface/Select_Interface/Select_Left.frame = int(left_press)
			$GUI/Interface/Select_Interface/Select_Right.frame = int(right_press)
			var adder = int(Input.is_action_just_released(str(player_id)+"browse_right"))-int(Input.is_action_just_released(str(player_id)+"browse_left"))
			browse_selection = posmod(browse_selection-1+adder,3)+1
			if browse_selection == 2: browse_selection += adder
			##BROWSE SELECTION CHANGED
			if adder != 0:
				snd_virus_browse.play()
				$GUI/Interface/Select_Interface/Select_Pointer.change(browse_selection-1,adder)
			update_GUI()
			
			#HANDLE PIP BOY SCREEN
			var current_level = virus_lvl[browse_selection-1]
			match browse_selection:
				ITEM.PLATFORM:
					$GUI/Interface/Select_Interface/SelectScreens/PlatformScreen/Counter.visible = timer[TIMER.PLATFORM] > 0
					$GUI/Interface/Select_Interface/SelectScreens/PlatformScreen/Button.visible = timer[TIMER.PLATFORM] == 0
					$GUI/Interface/Select_Interface/SelectScreens/PlatformScreen/Display.visible = timer[TIMER.PLATFORM] == 0
					$GUI/Interface/Indicators/SELECT0.visible = true
					$GUI/Interface/Indicators/SELECT2.visible = false
					#FLASH BATTERY WHEN LEVEL == 0 AND UTILITY BUTTON IS PRESSED
					if virus_lvl[browse_selection-1] == 0 && !utility_press_stopper && utility_released:
						$GUI/Interface/Indicators.get_child(0).blink = true
						continue
					#SET COUNTER IF TIMER'S STILL UP
					if timer[TIMER.PLATFORM] > 0:
						$GUI/Interface/Select_Interface/SelectScreens/PlatformScreen/Counter.num = int(timer[TIMER.PLATFORM])
					#DO EFFECT
					if !utility_press_stopper && utility_released && timer[TIMER.PLATFORM] == 0:
						var time = 4+current_level*3
						Admin.opponent_platform_halved(self,time)
						if current_level == 3: Admin.opponent_platform_move(self,time)
						timer[TIMER.PLATFORM] = time+5
				ITEM.FIREBALL:
					$GUI/Interface/Select_Interface/SelectScreens/FireballScreen/Whole/ColumnSelect.visible = false
					$GUI/Interface/Select_Interface/SelectScreens/FireballScreen/Whole/ButtonDisplay.frame = 0
					$GUI/Interface/Select_Interface/SelectScreens/FireballScreen/Counter.visible = timer[TIMER.FIREBALL] > 0
					$GUI/Interface/Select_Interface/SelectScreens/FireballScreen/Whole.visible = timer[TIMER.FIREBALL] == 0
					$GUI/Interface/Indicators/SELECT0.visible = false
					$GUI/Interface/Indicators/SELECT2.visible = true
					#FLASH BATTERY WHEN LEVEL == 0 AND UTILITY BUTTON IS PRESSED
					if virus_lvl[browse_selection-1] == 0 && Input.is_action_just_pressed(str(player_id)+"R2"):
						$GUI/Interface/Indicators.get_child(2).blink = true
						continue
					##SET COUNTER IF TIMER'S STILL UP
					if timer[TIMER.FIREBALL] > 0:
						$GUI/Interface/Select_Interface/SelectScreens/FireballScreen/Counter.num = int(timer[TIMER.FIREBALL])
					#AIM, AND STATE IS CHANGED TO STATE.FIREBALL_AIM
					if Input.is_action_just_pressed(str(player_id)+"R2") && timer[TIMER.FIREBALL] == 0:
						$GUI/Interface/Select_Interface/SelectScreens/FireballScreen/Whole/ButtonDisplay.frame = 1
						$GUI/Interface/Select_Interface/SelectScreens/FireballScreen/Whole/ColumnSelect.visible = true
						Admin.get_opponent_fireball_ui(self).enable_arrow(true)
						Admin.get_opponent_fireball_ui(self).set_arrow_position(1)
						set_tinker(true)
						timer[TIMER.FIREBALL_SHOOT] = .2
						state = STATE.FIREBALL_AIM
						return
						
		STATE.UPGRADE:
			$GUI/Interface/Loading.visible = true
			$GUI/Interface/Loading/UPGRADE.visible = true
			$GUI/Interface/Loading/HACK.visible = false
			$GUI/Interface/Loading/SECONDS/COUNT.frame = clamp(get_upgrade_timer()-floor(press_timer),0,9)
			press_timer = press_timer+delta if utility_press else 0
			##UPGRADE WHEN TIME IS UP
			if press_timer >= get_upgrade_timer():
				$snd_loading.stop()
				coins -= get_upgrade_cost()
				virus_lvl[held_upgrade-1] += 1
				held_upgrade = ITEM.NONE
				set_tinker(false)
				update_GUI()
				snd_virus_level_up.play()
				state = STATE.BROWSE
				return
			##DON'T UPGRADE WHEN BELOW TIME
			if !utility_press:
				$snd_loading.stop()
				set_tinker(false)
				update_GUI()
				Input.stop_joy_vibration(player_id)
				state = STATE.BROWSE
				
		STATE.FIREBALL_AIM:
			if Input.is_action_just_pressed(str(player_id)+"move_left"):
				fireball_column = posmod(fireball_column - 1,3)
				Admin.get_opponent_fireball_ui(self).set_arrow_position(fireball_column)
				
			if Input.is_action_just_pressed(str(player_id)+"move_right"):
				fireball_column = posmod(fireball_column + 1,3)
				Admin.get_opponent_fireball_ui(self).set_arrow_position(fireball_column)
			
			if !Input.is_action_pressed(str(player_id)+"R2") && timer[TIMER.FIREBALL_SHOOT] == 0:
				Admin.get_opponent_fireball_ui(self).enable_arrow(false)
				set_tinker(false)
				Admin.opponent_spawn_fireball(self,fireball_column,512 if virus_lvl[2] == 1 else 512*1.5,1 if virus_lvl[2] <= 2 else 2)
				fireball_column = 1
				timer[TIMER.FIREBALL] = 3
				state = STATE.BROWSE
	
	if !utility_press && utility_press_stopper:
		utility_press_stopper = false

func update_GUI():
	$GUI/Interface/Indicators/CoinCounter.num = coins
	$GUI/Interface/Indicators/Upgrade/Item.frame = held_upgrade
	$GUI/Interface/Indicators/Upgrade.frame = held_upgrade+3*int(tinker && held_upgrade > 0)
	$GUI/Interface/Indicators/Upgrade/Glow.visible = held_upgrade > 0
	$GUI/Interface/Indicators/Upgrade/Cost.visible = held_upgrade > 0
	if held_upgrade > 0:
		$GUI/Interface/Indicators/Upgrade/Cost.cost = get_upgrade_cost()
		
	var index = 0
	for i in virus_lvl:
		$GUI/Interface/Indicators.get_child(index).level = i
		var SelectScreen = $GUI/Interface/Select_Interface/SelectScreens.get_child(index)
		SelectScreen.visible = index == browse_selection-1
		SelectScreen.modulate = Color.white - Color(0,0,0,.5)*int(i == 0)
		index += 1

func _on_Player_item_recieved(platform):
	if platform.item == ITEM.COIN:
		snd_coin.play()
		coins += 1
		update_GUI()
		platform.free_item()
	elif held_upgrade == ITEM.NONE && virus_lvl[platform.item-1] < 3:
		snd_pickup_box.play()
		held_upgrade = platform.item
		update_GUI()
		platform.free_item()

func _on_Player_hit_by_obstacle(obstacle,damage:int):
	#if damage <= 0: return
	if !Admin.is_gameplay || !active: return
	var game = $ViewportContainer/Viewport/Game
	var player = game.obj_player
	var camera = game.obj_camera
	latest_object_collided = obstacle
	if obstacle.is_in_group("Void"):
		#INSTANT LOSE OMG
		UniTime.pause_sec(.4)
		deplete_lives(8)
	
	if !player.invincible:
		player.effect_whiten(true)
		#print("hi true")
		VisualServer.force_draw()
		UniTime.pause_sec(.075)
		#player.effect_whiten(false)
		#print("hi false")
		player.invincible = true
		player.do_hurt()
		camera.do_shake()
		deplete_lives(damage)
		$AnimationPlayer.play("Hit")
	#LOSE
	if lives <= 0:
		player.active = false
		player.set_collision_mask_bit(0, false)
		player.get_node("Audio3").set_bus("Delay")
		$ViewportContainer/Viewport/Game.obj_camera.is_following = false
		active = false
		Admin.white_flag(self)
		if obstacle.is_in_group("Void"):
			$TextureRect/AnimationPlayer.play("void")
		if obstacle.is_in_group("Fireball"):
			$TextureRect/AnimationPlayer.play("fire")
		Admin.is_gameplay = false
		
func win():
	var player = $ViewportContainer/Viewport/Game.obj_player
	$TextureRect/AnimationPlayer.play((["blue","orange"])[player_id])
	$ViewportContainer/Viewport/Game.obj_player.active = false
	if player._check_is_grounded():
		player.velocity.x = 0
	active = false
