extends Control

func enable_arrow(enable:bool) -> void:
	visible = enable

func set_arrow_position(index : int) -> void:
	$ColorRect.material.set_shader_param("index",index)

func _ready():
	visible = false
	var new_mat = $ColorRect.get_material().duplicate()
	$ColorRect.set_material(new_mat)
	get_viewport().connect("size_changed",self,"_on_Viewport_size_changed")
	_on_Viewport_size_changed()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_Viewport_size_changed():
	"""
	var vps = get_viewport().size
	obj_camera.zoom = Vector2.ONE*((RAG.base_x_num*16)/(vps.x/4.0))*2
	view_size = vps
	"""
	var vps = get_viewport().size
	var vps_x = stepify(vps.x/2.0,2)
	var vps_y = stepify(vps.y/2.0,2)
	$ColorRect.rect_size.x = 512/(720.0/vps_y)
	$ColorRect.rect_position.x = -$ColorRect.rect_size.x/2.0
