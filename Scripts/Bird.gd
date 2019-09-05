extends KinematicBody2D

const MAX_PATH_BIRD = 100 # distance parcourue par l'oiseau avant changement de direction
var stepBird=1 	# Vitesse de l'oiseau
var dirCount=MAX_PATH_BIRD # Distance avant changement de direction
var dirPath='H' 	# Direction de l'oiseau (V/H) horizontal/vertical
var dirBird=Vector2(1,0)
var tilemap

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = Vector2(90,500)
	if global_position.x<$'/root/Game/Player'.global_position.x:
		$Sprite.flip_h=true
	$Sprite.play('Profil')
	tilemap = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/TileMap')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# IA de l'oiseau
	var player=$'/root/Game/Player' 
	if player != null:
		var dest = player.global_position
		var pos = global_position
		
		if Constants.dontMoveEnemy == false:
			dirCount-=1
			# Déplace l'oiseau en direction du joueur
			var tilePos	= tilemap.world_to_map(position)
			var numTileUp		= tilemap.get_cellv(Vector2(tilePos.x, tilePos.y-0.3)) # Vérifie qu'il y a un tile au dessus
			var numTileDown	= tilemap.get_cellv(Vector2(tilePos.x, tilePos.y+1)) # Vérifie qu'il y a un tile au dessous
			var numTileLeft	= tilemap.get_cellv(Vector2(tilePos.x-1, tilePos.y)) # Vérifie qu'il y a un tile à gauche
			var numTileRight	= tilemap.get_cellv(Vector2(tilePos.x+1, tilePos.y)) # Vérifie qu'il y a un tile à droite
			
			if dirBird.y != 0:
				if numTileUp >= 0 or numTileDown >= 0:
					dirCount = 0
					dirPath = 'V' # Pour passer en mode horizontal
			if dirBird.x != 0:
				if numTileLeft >= 0 or numTileRight >= 0:
					dirCount = 0
					dirPath = 'H' # Pour passer en mode vertical
			
			# L'oiseau à fini son trajet horizontal ou vertical ?
			# alors on recalcule la direction rapport au joueur et  la nouvelle direction
			if dirCount <= 0:
				dirCount = MAX_PATH_BIRD
				if dirPath == 'H':
					dirPath = 'V' # changement de direction
					if pos.y <= dest.y:
						dirBird.y = stepBird
					else:
						dirBird.y =- stepBird
					dirBird.x = 0
					$Sprite.play('UpDown')
				else:
					dirPath = 'H'
					if pos.x <= dest.x:
						$Sprite.flip_h = true
						dirBird.x = stepBird
					else:
						$Sprite.flip_h = false
						dirBird.x =- stepBird
					dirBird.y = 0
					$Sprite.play('Profil')
			position += dirBird

func _on_Sprite_animation_finished():
	if $Sprite.animation == 'Catch':
		remove_child(self)
		queue_free()
