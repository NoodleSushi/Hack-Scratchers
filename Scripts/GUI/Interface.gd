extends Sprite
var noise := OpenSimplexNoise.new()
export(bool) var enable_noise = true
var def_y = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8
	def_y = position.y

var timer = 0

func _process(delta):
	timer += delta
	position.y = def_y+sin(timer) * 4
	if !enable_noise: return
	position.x = noise.get_noise_2d(timer*10,0)*4
	position.y = noise.get_noise_2d(timer*10,100)*4-32
	rotation_degrees = noise.get_noise_2d(timer*10,500)*1
	pass
