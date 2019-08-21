extends Node2D

var red = 0
var green = 0
var blue = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var timer = Timer.new()
	timer.connect('timeout',self,'_on_timer_color')
	add_child(timer)
	timer.start(0.1)
	# Affiche le score
	$Score.set_text('%08d'%(Constants.score))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Score.add_color_override('font_color', Color(red, green, blue))


func _on_timer_color():
	red = randf()
	green = randf()
	blue = randf()
