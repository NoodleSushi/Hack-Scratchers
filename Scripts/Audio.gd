extends Node

func new_sfx(object,path:String,loop_mode : int = 0):
	var sfx := AudioStreamPlayer.new()
	var stream = load(path)
	object.add_child(sfx)
	sfx.stream = stream
	if loop_mode != 0:
		sfx.stream.loop_mode = loop_mode
		#sfx.stream.loop_end = sfx.stream.get_length()
	return sfx
