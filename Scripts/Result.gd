extends Node2D

func _draw():
	if Constants.PLAY_SOUND == true:
		$Music.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	removeLevel()
	pause_mode=Node.PAUSE_MODE_INHERIT
	get_tree().paused=false
	# Ajuste le score
	match Constants.nbFireBombs:
		20:
			Constants.bonusFireBombs=10000
		21:
			Constants.bonusFireBombs=20000
		22:
			Constants.bonusFireBombs=30000
		23:
			Constants.bonusFireBombs=50000
	Constants.score+=Constants.bonusFireBombs

	$Bonus.set_text('%05d'%(Constants.bonusFireBombs))
	$NB_FireBomb.set_text('%02d'%(Constants.nbFireBombs))

	# Réinitialisation des variables pour le prochain niveau
	Constants.bonusFireBombs = 0
#	Constants.fireBombs		 = 0
	# Reset le nombre de firebomb pour le niveau suivant
	Constants.nbFireBombs	 = 0
	Constants.NbBombs			 = 0
	Constants.deadBird 		 = false
	Constants.dontMoveEnemy	 = false
	Constants.reTimer			 = false
	Constants.powerballActive= false
	Constants.powerballPoint = 0

func removeLevel():
	#Suppression du level courant
	var level = get_node('/root/Game/Levels/Level'+str(Constants.level))
	if level != null:
		level.queue_free()

func nextLevel():
	Constants.level += 1
	Constants.current_level += 1
	var nextLevel = File.new()
	if nextLevel.file_exists('res://Scenes/Level'+str(Constants.level)+'.tscn') == false:
	# On retourne au level 1 si fin de tous les levels
		Constants.level = 1

func _process(delta):
	OS.delay_msec(3000)

	# On a fait tous les niveaux, donc retour au menu
	if Constants.level+1 == 63:
		get_tree().change_scene('res://Scenes/Menu.tscn')
	else:
		nextLevel()
	get_tree().change_scene('res://Scenes/Game.tscn')
