extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	# formate le texte par défaut avec 8 zéros
	self.set_text('%08d'%(0))