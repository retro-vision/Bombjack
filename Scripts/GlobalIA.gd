extends KinematicBody2D

var SPEED_ENEMY = 60
var StepEnemY	 = 4
var dirX = 1
var dirY = 0
var direction

func flipSprite(status):
	var item = name
	if item == 'Snail':
		$Sprite.flip_h = status

# Called when the node enters the scene tree for the first time.
func _ready():
	dirY=-(randf() * StepEnemY) - 1
	direction = Vector2(dirX,dirY)*SPEED_ENEMY

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = $'/root/Game/Player' 
	if player != null:
		var dest = player.global_position
		var pos = global_position
	
		if Constants.dontMoveEnemy == false:
			if pos.x<dest.x:
				flipSprite(true)
				dirX = 1
			else:
				flipSprite(false)
				dirX = -1
				
			# Déplace l'alien en direction du joueur
			if $Sprite.animation != 'Appear':
				# Collision Haut ?
				if test_move(transform, Vector2(0,-1)):
					dirY = (randf() * StepEnemY) - 1
				# Collision Bas
				if test_move(transform, Vector2(0,1)):
					dirY = -(randf() * StepEnemY) - 1
				# Collision Gauche
				if test_move(transform, Vector2(-1,0)):
					flipSprite(true)
					dirX = 1
				# Collision Droite
				if test_move(transform, Vector2(1,0)):
					flipSprite(false)
					dirX = -1
		
				direction=Vector2(dirX,dirY)*SPEED_ENEMY 
				move_and_slide(direction)

func _on_Sprite_animation_finished():
	if $Sprite.animation == 'Appear':
		$Sprite.play('Default')
	if $Sprite.animation == 'Catch':
		remove_child(self)
		queue_free()
