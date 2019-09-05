extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_text('%02d'%(Constants.lives))

func _process(delta):
	self.set_text('%02d'%(Constants.lives))
