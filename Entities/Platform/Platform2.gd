extends Node2D

##########
#set_width
#set_move_type
#set_spikes_enable

#######

export(int) var width := 4
export(Texture) var texture;
export(bool) var is_one_way := false setget is_one_way_set;
export(Vector2) var origin := Vector2(0,0) setget set_origin;
export(int) var move_type = 0
var spikes_enable : bool = false setget set_spikes_enable;
var spikes_rise : bool = false
var ysize : int = 16;
var pos = Vector2()
var item = 0

"""
move_type:
	0 - none
	1 - left
	2 - center
	3 - right
"""
func normalize():
	$Platform/CollisionShape.disabled = false
func on_Mother_spike_changed(enable:bool):
	if !spikes_enable: return
	$Platform/Spike/AnimationPlayer.play(str(enable))
	spikes_rise = enable

func set_spikes_enable(val : bool):
	if !$VisibilityNotifier2D.is_on_screen() && !spikes_enable && val:
		spikes_enable = val
	if !val:
		spikes_enable = val

func set_move_type(val : int):
	if !$VisibilityNotifier2D.is_on_screen() && move_type == 0:
		move_type = val
	if val == 0:
		move_type = val
		if !$VisibilityNotifier2D.is_on_screen():
			position.x = pos.x

func set_width(val : int) -> void:
	if !$VisibilityNotifier2D.is_on_screen() && width != 3:
		width = val
	if val == 4:
		width = val
	update()

func update_posmove():
	match move_type:
		1: position.x = pos.x+64-cos(UniTime.pi2*2)*64
		2: position.x = pos.x+sin(UniTime.pi2)*192
		3: position.x = pos.x-64+cos(UniTime.pi2*2)*64
	pass

func _ready():
	if Engine.editor_hint && !has_node("Platform/Item"): return;
	if randf() > 0.3:
		free_item()
	elif randf() > 0.33:
		item = 0
	else:
		item = 1+2*(randi()%2)
	$Platform/Item/Sprite.frame = item

func free_item():
	if has_node("Platform/Item"):
		if $Platform/Item.is_connected("body_entered", self, "_on_Item_body_entered"):
			$Platform/Item.disconnect("body_entered", self, "_on_Item_body_entered")
		$Platform/Item.queue_free()

func _on_Item_body_entered(body):
	if body.is_in_group("Player"):
		body.emit_signal("item_recieved",self)

func set_origin(val : Vector2) -> void:
	origin = val
	if !(Engine.editor_hint):
		yield(self,'tree_entered')
	update()


func _physics_process(delta):
	if Engine.editor_hint: return
	update_posmove()

#export(Array, Rect2) var region_rect_list = [Rect2(104,176,16,16),Rect2(120,176,16,16),Rect2(136,176,16,16)];

func is_one_way_set(val : bool) -> void:
	is_one_way = val
	if !(Engine.editor_hint):
		#yield(self,'tree_entered')
		$Platform/CollisionShape.one_way_collision = val
	
func change_pos(vec2:Vector2) -> void:
	pos += vec2
	position.y = pos.y
	update_posmove()

func set_pos(vec2:Vector2) -> void:
	pos = vec2
	position = vec2
	update_posmove()

func _draw():
	if $Platform.has_node("Item"):
		$Platform/Item.position.x = origin.x*ysize*width
		$Platform/Item.position.y = origin.y*ysize-40
	if $Platform.has_node("Spike"):
		$Platform/Spike.position.x = origin.x*ysize*width
		$Platform/Spike.position.y = origin.y*ysize-16
	$Platform/CollisionShape.scale.x = ysize*width
	$Platform/CollisionShape.position = origin*Vector2(ysize*width,ysize)+Vector2.UP*14
	var colsize : Vector2 = Vector2(ysize*width,ysize)
	var tilsize : Vector2 = Vector2.ONE*colsize.y*2
	#draw_texture_rect_region(texture,Rect2(Vector2.ZERO,Vector2(48,16)), Rect2(104,176,48,16) )
	#draw_texture_rect_region(test,Rect2(Vector2.ONE*24,Vector2(48,24)),Rect2(Vector2.ONE*24,Vector2.ONE*48))
	for i in range(width):
		var pos := Vector2(-colsize.x+(colsize.x*i*2)/width,-colsize.y)
		pos += origin*Vector2(ysize*width,ysize)
		if width == 1:
			var tilsize_h = tilsize*Vector2(.5,1)
			draw_texture_rect_region(texture,Rect2(pos,tilsize_h), Rect2( Vector2(0,0), Vector2(8,16) ) )
			draw_texture_rect_region(texture,Rect2(pos+Vector2.RIGHT*ysize,tilsize_h), Rect2( Vector2(40,0), Vector2(8,16) ) )
		else:
			var xin = 0
			match (i+1):
				1: xin = 0
				width: xin = 2
				_: xin = 1
			draw_texture_rect_region(texture,Rect2(pos,tilsize), Rect2(xin*16, 0 ,16, 16) )
