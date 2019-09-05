extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	# formate le texte par défaut avec 2 zéros
	self.set_text('%02d'%(0))
	