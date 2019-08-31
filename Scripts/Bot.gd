extends KinematicBody2D

const MAX_ENEMY = 5
enum Enemy {SNAIL=0, BALL1=1, BALL2=2, SOUCOUPE=3, DRONE=4}

const GRAVITY	= 1000
const MAX_CHECK	= 2

var speedBot		= 65
var direction		= Vector2()
var checkStop		= 0 # Nombre de fois que le robot bute avant de tomber
var snailScene		= preload('res://Scenes/Snail.tscn')
var ball1Scene		= preload('res://Scenes/Ball1.tscn')
var ball2Scene		= preload('res://Scenes/Ball2.tscn')
var soucoupeScene	= preload('res://Scenes/Soucoupe.tscn')
var droneScene		= preload('res://Scenes/Drone.tscn')
export var firstBot = true
var lastCheck = false
var collideOtherAlien = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

# -1 si tile vide
# 0 si tile bloquant
# 1 si autre tile
func matchTiles(numTile):
	var returnCode = 0
	if numTile < 0 :
		returnCode = -1
	elif numTile == 1 or numTile == 2 or numTile == 3 or numTile == 4 or numTile == 5 or numTile == 6:
		returnCode = 0
	else:
		returnCode = 1
	return returnCode
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		# Ne fait pas bouger l'apparition du robot
	if $Sprite.animation == 'Appear':
		direction.x = 0
	if Constants.dontMoveEnemy == false:
		var tilemap = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/TileMap')
		var tilePos = tilemap.world_to_map(position)
		# On marche
		if is_on_floor() and $Sprite.animation != 'Appear':
			# IA du robot
			$Sprite.play('Walk')
			var numTileL = tilemap.get_cellv(Vector2(tilePos.x-1, tilePos.y+1)) # Vérifie qu'il y a un tile sous la position N-1
			var numTileR = tilemap.get_cellv(Vector2(tilePos.x+1, tilePos.y+1)) # Vérifie qu'il y a un tile sous la position N+1
			var checkLeft = matchTiles(numTileL)
			var checkRight = matchTiles(numTileR)
			# Teste le nombre de butées
			if checkStop < MAX_CHECK:
				# Teste la butée gauche
				if checkLeft < 0 or checkLeft == 0:
					$Sprite.flip_h = false
					speedBot = abs(speedBot)
					checkStop += 1
				# Teste la butée droite
				if checkRight < 0 or checkRight == 0:
					$Sprite.flip_h = true
					speedBot = -speedBot
					checkStop += 1
			else:
				# Teste la butée gauche
				if lastCheck == false and checkLeft == 0:
					$Sprite.flip_h = false
					speedBot = abs(speedBot)
					lastCheck = true
				# Teste la butée droite
				elif lastCheck == false and checkRight == 0:
					$Sprite.flip_h = true
					speedBot = -speedBot
					lastCheck = true
			# Si collision avec un autre robot ou alien alors on change de direction
			if test_move(transform, Vector2(-1,0)) == true or test_move(transform, Vector2(1,0)) == true:
				if $Sprite.flip_h == true:
					$Sprite.flip_h = false
				else:
					$Sprite.flip_h = true
				speedBot =-speedBot

			direction.x = speedBot
		else: # On tombe
			var numTileD = tilemap.get_cellv(Vector2(tilePos.x, tilePos.y+1)) # Vérifie qu'il y a un tile sous la position N+1
			var checkDown = matchTiles(numTileD)
			if checkDown == -1:
	#			if $Sprite.animation != 'Appear':
				if $Sprite.animation == 'Walk':
					$Sprite.play('Down')
					checkStop = 0
					direction.x = 0
				if $Sprite.animation == 'Down':
					if name == 'Bot'+str(Constants.nbRobot):
						if firstBot == true:
							print('Bot Tombe')
							if Constants.nbRobot < Constants.MAX_BOT:
								print('Retimer BOT')
								var timer = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/timer')
								timer.start(Constants.BOT_TIMER)
								Constants.nbRobot += 1
								Constants.reTimer = true
							if test_move(transform, position) == true:
								firstBot = false
					lastCheck = false
		if $Sprite.animation != "Appear":
			direction.y += GRAVITY * delta
			direction = move_and_slide(direction, Vector2(0, -1))
	
		# On a atteind le sol du niveau donc on supprime le robot pour faire apparaitre l'escargot
		if global_position.y > 550:
			queue_free()
			var enemy=null
			# Ajoute l'ennemi
			match randi()%MAX_ENEMY:
				Enemy.SNAIL:
					enemy = snailScene.instance()
				Enemy.BALL1:
					enemy = ball1Scene.instance()
				Enemy.BALL2:
					enemy = ball2Scene.instance()
				Enemy.SOUCOUPE:
					enemy = soucoupeScene.instance()
				Enemy.DRONE:
					enemy = droneScene.instance()
	
			enemy.position = position
			enemy.get_child(0).play('Appear')
			$'/root/Game/Aliens'.add_child(enemy)

func _on_Sprite_animation_finished():
	if $Sprite.animation == 'Appear':
		speedBot = -speedBot
		$Sprite.flip_h = true
		$Sprite.play('Walk')
		direction.x = speedBot
	if $Sprite.animation == 'Catch':
		remove_child(self)
		queue_free()
