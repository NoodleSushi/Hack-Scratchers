extends Node

func _ready():
	get_tree().connect("screen_resized", self, "resize")


func resize():
	var baseWidth = 256.0
	var baseHeight = 128.0
	var windowSize = OS.get_window_size()
	
	#can't snap to a size bigger than the screen
	var maxSize = OS.get_screen_size(0)
	maxSize = min(maxSize.x, maxSize.y)
	maxSize = int(baseWidth * round(float(maxSize)/baseWidth)) #this assumes the game is wider than it is tall
	
	#snap to perfect pixel sizes
	var newX = clamp(int(baseWidth * round(float(windowSize.x)/baseWidth)), baseWidth, maxSize)
	var newY = int(newX * (baseHeight / baseWidth))
	
	OS.set_window_size(Vector2(newX, newY))
