extends Node2D

const MAX_SCORE = 10

var Score = {SCORE=0, MENU=1}
var HiScoresMutex = Score.MENU
var scoreName = ['Robert', 'Olivier', 'Jean', 'Paul', 'Nicolas', 'Pierre', 'Emmanuel' ,'Laurent', 'Didier', 'Andre', 'Francois', 'David']
var red = 0
var green = 0
var blue = 0

func updateHiScores():
	var node = get_node('HiScores')
	var index = 0
	for item in node.get_children():
		if item.name.find('Line') >= 0:
			for label in item.get_children():
				match label.name:
					'Score':
						label.set_text('%08d'%(Constants.hiScores[index][0]))
					'Name':
						label.set_text(Constants.hiScores[index][1])
					'Level':
						label.set_text('%03d'%(Constants.hiScores[index][2]))
			index += 1

func createOrLoadScore():
	var file = File.new()
	var score = 20010960
	var level = 255
	var name = 'Bondavalli'
	# Créé le fichier des scores s'il n'existe pas
	if file.file_exists(Constants.FILE_NAME_SCORES) == false:
		print('Création du tableau des scores')
		file.open(Constants.FILE_NAME_SCORES, File.WRITE)
		file.store_32(score)
		file.store_line(name)
		file.store_8(level)
		Constants.hiScores[0] = [score, name,level]
		randomize()
		var maxi = 100000
		for item in range(1,MAX_SCORE):
			score = (randi()%maxi)+2000
			# Choisi un nom aléatoirement dans le tableau
			name = scoreName[randi()%len(scoreName)]
			level = randi()%12+5
			file.store_32(score)
			file.store_line(name)
			file.store_8(level)
			Constants.hiScores[item] = [score, name, level]
			# Pour le tri décroissant
			maxi = score
		# Affiche les score créés
		for item in Constants.hiScores:
			print('Add: ', item, ' : ', Constants.hiScores[item])
		file.close()
	else:
		# Charge les Hiscores
		print('Chargment des HiScores')
		file.open(Constants.FILE_NAME_SCORES, File.READ)
		for item in range(MAX_SCORE):
			score = file.get_32()
			name = file.get_line()
			level = file.get_8()
			Constants.hiScores[item]=[score, name, level]
		file.close()

func _ready():

	if Constants.fullscreen == true:
		OS.window_fullscreen = true
		Constants.fullscreen = true
	pause_mode=Node.PAUSE_MODE_INHERIT
	get_tree().paused=false
	# Active les sons et musiques ou pas
	if OS.is_debug_build():
		Constants.PLAY_SOUND = false
	else:
		Constants.PLAY_SOUND = true
	# Initialation des variables
	Constants.level	= 1 # Niveau courant
	Constants.score	= 0 # Score
	Constants.lives	= 3 # Total des vies
	Constants.NbBombs	= 0 # Nombres de bombes gobées
	Constants.nbRobot	= 1 # Compteur d'apparition des robots
	Constants.botInitPos = Vector2(0,0) # Pos du 1er niveau
	Constants.deadOrWinerBJ = false
	Constants.deadBird = false

	Constants.bonusFactor 	 	= 0 # Facteur multiplicateur de points
	Constants.bonusFireBombs 	= 0 # Bonus des bombes allumées en fin de niveau
#	Constants.fireBombs 		 	= 0 # Nombre de firebombs
	Constants.nbFireBombs		= 0 # Compteur de bombes allumées gobées pour bonus de fin de niveau
	Constants.powerballPoint 	= 0.0 # Compteur pour faire apparaitre la powerball
	Constants.powerballActive	= false # Semaphore pour n'avoir toujours qu'une powerball active

	Constants.dontMoveEnemy = false # Fige les ennemies pendant la powerball
	Constants.reTimer 		= false # Timer pour la réapparition des robots
	# Chargement des Hiscores ou création des HiScores s'ils n'existent pas
	createOrLoadScore()
	# Met à jour les labels du tableau des scores
	updateHiScores()
	# Affiche le Hiscore en bas dans le menu
	get_node('UI/Hiscore').set_text(str(Constants.hiScores[0][0]))
	# Affiche le round du hiscore dans le menu
	get_node('UI/Round').set_text('-'+str(Constants.hiScores[0][2])+'-')
	# Créé le timer pour l'apparition du tableau des scores
	var timer = Timer.new()
	timer.connect('timeout',self,'_on_timer_timeoutHiScore')
	timer.name='timerHiScore'
	var node = get_node('/root/Menu/timerHiScore')
	if node == null:
		self.add_child(timer)
		timer.start(5)
	# timer pour changement des couleurs du Hi score
	timer = Timer.new()
	timer.connect('timeout',self,'_on_timer_timeoutColor')
	timer.name='timerColor'
	self.add_child(timer)
	timer.start(.1)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

# Called when the node enters the scene tree for the first time.
func _draw():
	if Constants.PLAY_SOUND==true:
		$Music.playing=true
	# Affiche le tableau des scores si game over
	if Constants.putScore == true:
		HiScoresMutex = Score.SCORE
		$HiScores.show()
		Constants.putScore=false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Input.is_action_just_pressed('ui_cancel')):
		get_tree().quit()
	# Lance le jeu
	if(Input.is_action_just_pressed('kp_1')):
		get_tree().change_scene('res://Scenes/Game.tscn')

	# Passage en fullscreen et inversement
	if(Input.is_action_just_released('kp_f')):
		if Constants.fullscreen==false:
			OS.window_fullscreen=true
			Constants.fullscreen=true
		else:
			OS.window_fullscreen=false
			Constants.fullscreen=false
	# Animation des couleurs HiScore
	$'HiScores/Line1/Score'.add_color_override('font_color', Color(red, green, blue))
	$'HiScores/Line1/Level'.add_color_override('font_color', Color(red, green, blue))
	$'HiScores/Line1/Name'.add_color_override('font_color', Color(red, green, blue))
	# Animation des couleurs du menu
	$'UI/Players'.add_color_override('font_color', Color(red, green, blue))

func _on_timer_timeoutHiScore():
	if HiScoresMutex == Score.MENU:
		HiScoresMutex = Score.SCORE
		$HiScores.show()
	else:
		HiScoresMutex = Score.MENU
		$HiScores.hide()

func _on_timer_timeoutColor():
	red = randf()
	green = randf()
	blue = randf()
