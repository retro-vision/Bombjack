extends KinematicBody2D

const SPEED_PB = 60
const StepPB = 4
var dirX = 1
var dirY = 0
var direction

	
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

	dirY=-(randf() * StepPB) - 1
	direction = Vector2(dirX,dirY)*SPEED_PB
	# Position aléatoire dans le niveau
	position = Vector2((randi()%648-24)+24,(randi()%600-24)+24)
	# Si powerball est en collision on rechange la position
	while test_move(transform, position):
		position = Vector2((randi()%648-24)+24,(randi()%600-24)+24)

	Constants.powerballPoint = 0
	Constants.powerballActive = true
	$Sprite.play('Blue')
	if Constants.PLAY_SOUND == true:
		# Stop tous les sons
		print('Stop music: ','/root/Game/Levels/Level'+str(Constants.level)+'/Music')
		print('Stop music: ', '/root/Game/Player/SpecialCoin')
		var zic = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/Music')
		zic.stop()
		zic = get_node('/root/Game/Player/SpecialCoin')
		zic.stop()
		print('Play music: ', $PowerballSound.name)
		$PowerballSound.play()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Déplace la powerball aléatoirement
	# Collision Haut ?
	if test_move(transform, Vector2(0,-1)):
		dirY=(randf() * StepPB) - 1
	# Collision Bas
	if test_move(transform, Vector2(0,1)):
		dirY=-(randf() * StepPB) - 1
	# Collision Gauche
	if test_move(transform, Vector2(-1,0)):
		dirX=1
	# Collision Droite
	if test_move(transform, Vector2(1,0)):
		dirX=-1

	direction=Vector2(dirX,dirY)*SPEED_PB 
	move_and_slide(direction)
