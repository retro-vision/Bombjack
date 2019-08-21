extends KinematicBody2D

const SPEED = 60
const Step = 4
var dirX = 1
var dirY = 0
var direction

	
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

	dirY=-(randf() * Step) - 1
	direction = Vector2(dirX,dirY)*SPEED
	# Position aléatoire dans le niveau
	position = Vector2((randi()%648-24)+24,(randi()%600-24)+24)
	# Si le bonus est en collision on rechange la position
	while test_move(transform, position):
		position = Vector2((randi()%648-24)+24,(randi()%600-24)+24)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Déplace le bonus aléatoirement
	# Collision Haut ?
	if test_move(transform, Vector2(0,-1)):
		dirY=(randf() * Step) - 1
	# Collision Bas
	if test_move(transform, Vector2(0,1)):
		dirY=-(randf() * Step) - 1
	# Collision Gauche
	if test_move(transform, Vector2(-1,0)):
		dirX=1
	# Collision Droite
	if test_move(transform, Vector2(1,0)):
		dirX=-1

	direction=Vector2(dirX,dirY)*SPEED
	move_and_slide(direction)
