extends StaticBody2D
tool
export(int) var width := 2 setget set_width
export(Texture) var texture;
export(bool) var is_one_way := false setget is_one_way_set;
export(Vector2) var origin := Vector2(0,0) setget set_origin;
var ysize : int = 16;

func _ready():
	if randf() > 0.15 && !(Engine.editor_hint): delete_coin()

func delete_coin():
	$Coin.disconnect("body_entered", self, "_on_Coin_body_entered")
	$Coin.queue_free()

func set_origin(val : Vector2) -> void:
	origin = val
	if !(Engine.editor_hint):
		yield(self,'tree_entered')
	update()

#export(Array, Rect2) var region_rect_list = [Rect2(104,176,16,16),Rect2(120,176,16,16),Rect2(136,176,16,16)];
func set_width(val : int) -> void:
	width = val
	if !(Engine.editor_hint):
		yield(self,'tree_entered')
	update()

func is_one_way_set(val : bool) -> void:
	is_one_way = val
	if !(Engine.editor_hint):
		#yield(self,'tree_entered')
		$CollisionShape.one_way_collision = val
	
func _draw():
	if has_node("Coin"):
		$Coin.position.x = origin.x*ysize*width
	$CollisionShape.scale.x = ysize*width
	$CollisionShape.position = origin*Vector2(ysize*width,ysize)
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


func _on_Coin_body_entered(body):
	if body.is_in_group("Player"):
		body.emit_signal("coin_recieved")
		delete_coin()
