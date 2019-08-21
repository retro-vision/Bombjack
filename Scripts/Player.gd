extends KinematicBody2D

# attributs du joueur
const RUN_SPEED	= 200
const JUMP_SPEED 	= -600
const GRAVITY 		= 1000
const MAX_BLINK	= 12 # Nombre de clignotement
const MAX_SCORE	= 10

var velocity 	= Vector2()
var regex 		= RegEx.new()
var animBackup = {} # dictionnaire pour sauver l'animation avant bonus

const respawnPosPlayer	= Vector2(330,258)

var countBlink = 0 # Compteur de clignotement
var flagBlink = false # Flag pour alterner le clignotement

func launchStart():
		var startScene = preload('res://Scenes/Start.tscn')
		var start = startScene.instance()
		start.name = 'Start'
		$'/root/Game/CanvasLayer'.add_child(start)

func _draw():
	# Lance l'animation de start
	launchStart()
	position=respawnPosPlayer
	# Supprime les robots
	resetAllAliens()
	# Affiche le score à l'init de la partie
	update_score(0)

func _init():
	set_process(true)
	
func nextPowerballColor():
	var powerBall = get_node('/root/Game/Bonus/PowerBallP')
	# Change la couleur de la powerball à chaque saut
	if powerBall!= null and Constants.powerballActive == true:
		var powerB = powerBall.get_node('Sprite')
		var index = Constants.PBColors.find(powerB.animation)
		if index == Constants.PBColors.size()-1:
			index = 0
		else:
			index += 1
		powerB.play(Constants.PBColors[index])
	
	
func get_input():

	velocity.x = 0
	var up		= Input.is_action_pressed('ui_up')
	var right	= Input.is_action_pressed('ui_right')
	var left 	= Input.is_action_pressed('ui_left')
	var jump 	= Input.is_action_just_pressed('ui_select')
	var jump_release = Input.is_action_just_released('ui_select')
	
	# On monte droit
	if velocity.y < 0 and left:
		$Sprite.flip_h = false
		$Sprite.play('JumpDiag')
	elif velocity.y < 0 and right:
		$Sprite.flip_h = true
		$Sprite.play('JumpDiag')
	elif velocity.y > 0 and left:
		$Sprite.flip_h = false
		$Sprite.play('DownDiag')
	elif velocity.y > 0 and right:
		$Sprite.flip_h = true
		$Sprite.play('DownDiag')
	elif velocity.y < 0:
		$Sprite.play('Jump')
	# On descend droit
	elif velocity.y > 0:
		$Sprite.play('Down')

	if is_on_floor():
		if right:
			$Sprite.play('Walk')
			$Sprite.flip_h = true
		elif left:
			$Sprite.play('Walk')
			$Sprite.flip_h = false
		elif(Input.is_action_just_released('ui_right') or Input.is_action_just_released('ui_left')):
			$Sprite.playing = false
			if $Sprite.frame == 0:
				$Sprite.frame = 1
			else:
				$Sprite.frame = 0
		else:
			if $Sprite.animation == 'Down':
				$Sprite.play('Start')
	if is_on_floor() and jump :
		if Constants.powerballActive == true:
			nextPowerballColor()
		# Super jump
		if up:
			velocity.y = JUMP_SPEED*1.7
		# stadard jump
		else:
			velocity.y = JUMP_SPEED*1.2
	else:
		# Redescend si on relache le saut
		if jump_release:
			if velocity.y < 0:
				velocity.y += 200
			
		# Ralentissement à la descente
		if not velocity.y < 0 and jump:
			velocity.y -= 300
			# empeche le joueur de remonter. Controle la descente
	#		if velocity.y < 0:
	#			velocity.y =- 50
			nextPowerballColor()
			update_score(Constants.BONUS_JUMP*Constants.bonusFactor)
			
		# Controle la vitesse de la descente
		if velocity.y > 200:
			velocity.y = 150
			
	velocity.x = -int(left)+int(right)

func createBird():
	if Constants.deadBird == true:
		var bird = $'/root/Game/Aliens/Bird'
		if bird != null:
			bird.queue_free()
			
		var birdScene=preload('res://Scenes/Bird.tscn')
		# Instancie l'oiseau 
		bird=birdScene.instance()
		$'/root/Game/Aliens'.add_child(bird)
		bird.get_node('Sprite').play('Profil')
		Constants.deadBird = false


func blinkBonus():
	countBlink += 1
	Constants.powerballActive = true
	# Alterne entre bonus et alien
	if flagBlink == false:
		for item in $'/root/Game/Aliens'.get_children():
			item.get_node('Sprite').play(animBackup[item.name])
		flagBlink = true
	else:
		for item in $'/root/Game/Aliens'.get_children():
			item.get_node('Sprite').play('Bonus')
		flagBlink = false
		
	if countBlink > MAX_BLINK:
		countBlink = 0
		Constants.dontMoveEnemy = false
		$'/root/Game/Levels/timerBlink'.queue_free()
		# Replace les ennemies dans leurs états d'origine
		for item in $'/root/Game/Aliens'.get_children():
			if animBackup[item.name]:
				item.get_node('Sprite').play(animBackup[item.name])
				print('réactive la zone de collision')
				# Réactive la zone de collision
				item.get_node('CollisionShape2D').set_deferred('disabled', false)
		# Relance le timer robot dans le cas ou il n'y a plus de robot ou si le 1er robot n'est plus
		if Constants.firstBot == true or Constants.nbRobot == 0:
			print('Relance le timer des robots')
			var timer = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/timer')
			timer.start(Constants.BOT_TIMER)
			Constants.reTimer=true
		# Vide le tableau de backup
		animBackup={}
		# Si l'oiseau est détruit alors on le recréé
		createBird()
		Constants.powerballActive = false
#		var timer = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/timer')
#		timer.start(Constants.BOT_TIMER)

		if Constants.PLAY_SOUND == true:
			$SpecialCoin.stop()
			var pbZic = get_node('/root/Game/Bonus/PowerBallP/PowerballSound')
			if pbZic != null:
				pbZic.stop()
			var zic = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/Music')
			zic.play()

		
func _physics_process(delta):
	if get_tree().paused == false:
		get_input()
		
		velocity.x *= RUN_SPEED
		velocity.y += GRAVITY * delta
		velocity = move_and_slide(velocity, Vector2(0, -1))

func update_score(points):
	Constants.score += points*Constants.bonusFactor
	var score_node = get_node('/root/Game/CanvasLayer/Score')
	score_node.set_text('%08d'%(Constants.score)) # formate le score

# Test des collisions
func _on_Area2D_area_entered(area):
	# Collision Aliens
	if area.name == 'Collide':
		collideAliens(area)
	# Collision  PowerBall
	elif area.name == 'CollidePBP':
		# Desactive la zone de collision
		area.get_node('CollisionShape2D').set_deferred('disabled', true)
		var zic = $'/root/Game/Bonus/PowerBallP/PowerballSound'
		if zic != null:
			zic.stop()
		var timer = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/timerOutPB')
		timer.queue_free() 
		timer = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/timer')
		timer.stop()
		enemyToBonus()
	elif area.name == 'CollideBonusE':
		# Desactive la zone de collision
		area.get_node('CollisionShape2D').set_deferred('disabled', true)
		# Supprime le bonus
		area.get_parent().queue_free()
		update_score(1000)
		if Constants.lives < 5:
			Constants.lives += 1
	elif area.name == 'CollideBonusB':
		# Desactive la zone de collision
		area.get_node('CollisionShape2D').set_deferred('disabled', true)
		# Supprime le bonus
		area.get_parent().queue_free()
		update_score(1000)
		if Constants.bonusFactor < 5:
			Constants.bonusFactor += 1
	# Collision Bombes
	else:
		collideBombs(area)

func respawnObjects():
	position = respawnPosPlayer
	createBird()

func collideBombs(area):
	regex.compile('[0-9]+$')
	var child = area.get_child(0)
	
	if child.name == 'Bomb':
		var numBomb = int(regex.search(area.name).get_string())
		var parent 	= area.get_parent()
		
		if child.animation == 'Active' or child.animation == 'Idle':
			if Constants.NbBombs < 24:
				Constants.NbBombs += 1

		if child.animation == 'Active':
#			Constants.fireBombs += 1
			Constants.nbFireBombs +=1
			if Constants.powerballActive == false:
				Constants.powerballPoint += 1
			child.play('CatchBonus')

			if Constants.PLAY_SOUND == true:
				$CatchSound.play()
			# Active la prochaine bombe
			for item in range(numBomb+1,24):
				var node = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/Bombs/Bomb'+str(item)+'/Bomb')
				if node != null and node.animation == 'Idle':
					node.play('Active')
					break
			update_score(Constants.BOMB_ACTIVE_POINTS*Constants.bonusFactor)
		elif child.animation == 'Idle':
			if Constants.powerballActive == false:
				Constants.powerballPoint += 0.5
				print('Fire bomb: ',Constants.powerballPoint)
			child.play('Catch')
			if Constants.PLAY_SOUND == true:
				$CatchSound.play()
			# si première bombe, on active la suivante
			for item in parent.get_children():
				var itemB = item.get_child(0)
				if parent.get_child_count() > 1:
					if itemB.animation == 'Idle' or itemB.animation == 'Active':
						itemB.play('Active')
						break
				else:
					# catch la dernière bombe
					itemB.play('Catch')
					break
			update_score(Constants.BOMB_IDLE_POINTS*Constants.bonusFactor)
			
		# Fin de niveau ?
		if Constants.NbBombs == 24:
			var zic = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/Music')
			zic.stop()
			$SpecialCoin.stop()
			if Constants.PLAY_SOUND == true:
				$WinnerSound.play()
			$Sprite.play('Winner')
			pause_mode = Node.PAUSE_MODE_PROCESS
			get_tree().paused = true

func catchBonus(item):
	if countBlink == 0:
		var timer
		if item.name.find('Bot') >= 0:
			Constants.nbRobot -= 1
			if item.firstBot == true:
				print('Catche first robot')
#				Constants.reTimer = true
				Constants.firstBot = true
				
		if item.name.find('Bird') >= 0:
			Constants.deadBird = true
		item.get_node('Sprite').play('Catch')
		# Ajuste le score avec la valeur de la powerball
		update_score(Constants.powerballPoint*Constants.bonusFactor)
		if Constants.PLAY_SOUND == true:
			$CatchSoundBonus.play()
		# Si on a pris tous les bonus on supprime le timer et fait réapparaitre les monstres
		var node = get_node('/root/Game/Aliens/')
		if node.get_child_count() == 0:
			timer = get_node('/root/Game/Levels/timerBlink')
			timer.queue_free()
			# Réactive le timer 
			if item.firstBot == true:
				Constants.firstBot = true
#				timer = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/timer')
#				timer.start(Constants.BOT_TIMER)
#				Constants.reTimer=false
	
func initPBTimer():
	var timer = Timer.new()
	timer.connect('timeout',self,'_on_timer_timeout') 
	timer.name='timerPB'
	get_node('/root/Game/Levels').add_child(timer)
	timer.start(5)

func enemyToBonus():
	# Sauvegarde de l'animation des aliens avant affichage des bonus 
	for item in $'/root/Game/Aliens'.get_children():
		var name = item.name
		var anim = item.get_node('Sprite').animation
		animBackup[name] = anim
		# Transforme les ennemies en bonus
		item.get_node('Sprite').play('Bonus')
		# Desactive la zone de collision
		item.get_node('CollisionShape2D').set_deferred('disabled', true)
		
	# Ne fait plus bouger les ennemies
	Constants.dontMoveEnemy = true
	# Récupère les points de la powerball
	var powerB = $'/root/Game/Bonus/PowerBallP'.get_node('Sprite').animation
	var index = Constants.PBColors.find(powerB)
	Constants.powerballPoint = Constants.PBPoints[index]
	# Supprime la powerball
	$'/root/Game/Bonus/PowerBallP'.queue_free()
#	Constants.powerballActive = false
#	Constants.fireBombs = 0
	Constants.powerballPoint = 0
	if Constants.PLAY_SOUND == true:
		$SpecialCoin.play()
		var zic = get_node('/root/Game/Bonus/PowerBallP/PowerballSound')
		if zic != null:
			zic.stop()
		zic = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/Music')
		zic.stop()
	# Désactive le timer pour les robots
	Constants.reTimer = false
	get_node('/root/Game/Levels/Level'+str(Constants.level)+'/timer').stop()
	# Active le timer des bonus. Penser à remettre le timer robots si nombre de robots < 4
	initPBTimer()
	
func collideAliens(area):
	if Constants.cheat == false:
		# Collision avec les ennemis
		var parent = area.get_parent().get_node('Sprite').animation
	
		if parent == 'Bonus' or parent == 'Catch':
			if countBlink == 0:
				catchBonus(area.get_parent())
		else:
	
			if Constants.PLAY_SOUND == true:
				$DeadSound.play()
				var zic = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/Music')
				zic.stop()
				zic = get_node('/root/Game/Bonus/PowerBallP/PowerballSound')
				if zic != null:
					zic.stop()
				$SpecialCoin.stop()
			# Désactivation de la bombe
			var node = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/Bombs/')
			for item in node.get_children():
				if item.get_child(0).animation == 'Active':
					item.get_child(0).play('Idle')
					break
			# Animation du joueur mort
			$Sprite.play('Dead')
			pause_mode = Node.PAUSE_MODE_PROCESS
			get_tree().paused = true
			Constants.lives -= 1
			Constants.dontMoveEnemy = false
			Constants.bonusFireBombs = 0
			Constants.powerballPoint = 0
			Constants.powerballActive = false
			Constants.deadBird = true # Pour recréer l'oiseau
			Constants.reTimer = true
			# Vide le tableau de backup
			animBackup={}

# Supprime tous les aliens sauf l'oiseau
func resetAllAliens():
	for item in $'/root/Game/Aliens'.get_children():
		if item.name != 'Bird':
			item.queue_free()
			Constants.deadBird = true
	for item in $'/root/Game/Bonus'.get_children():
		item.queue_free()
	# Reset la powerball et le nombre de firebomb attrapées
	Constants.powerballActive = false
	Constants.bonusFireBombs = 0
	var node = $'/root/Game/Levels/timerBlink'
	if node != null:
		node.queue_free()
	respawnObjects()

func _on_Sprite_animation_finished():
	var timer = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/timer')
	if $Sprite.animation == 'Dead':
		get_parent().pause_mode = Node.PAUSE_MODE_INHERIT
		get_tree().paused = false
		# Game Over
			# Plus de vie alors on retourne au menu. 
		if Constants.lives == 0:
			if Constants.PLAY_SOUND == true:
				$SpecialCoin.stop()
				var zic = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/Music')
				zic.stop()
				zic = get_node('/root/Game/Bonus/PowerBallP/PowerballSound')
				if zic != null:
					zic.stop()
				$GameOver.play()
				OS.delay_msec(5000)
			var goToScore = false
			# Si score plus petit que le score mini dans les scores, alors on n'appelle pas EntryName
			for item in range(MAX_SCORE):
				print(Constants.score,' : ', Constants.hiScores[item][0])
				if Constants.score > Constants.hiScores[item][0]:
					print('Go to score')
					goToScore = true
					get_tree().change_scene('res://Scenes/EnterName.tscn')
					break
			if goToScore == false:
				get_tree().change_scene('res://Scenes/Menu.tscn')

		Constants.dontMoveEnemy = false
		Constants.bonusFireBombs = 0
		Constants.powerballPoint = 0
		Constants.powerballActive = false
		resetAllAliens()
#		respawnObjects()
		timer.start(Constants.BOT_TIMER)
		Constants.reTimer = true
		Constants.nbRobot = 0
		$Sprite.play('Start')

		if Constants.PLAY_SOUND == true:
			$SpecialCoin.stop()
			$DeadSound.stop()
			var zic = get_node('/root/Game/Bonus/PowerBallP/PowerballSound')
			if zic != null:
				zic.stop()
			zic = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/Music')
			zic.play()
#			var zic = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/Music')
#			zic.play()
		# Supprime bombjack et le réinstancie
		Constants.deadOrWinerBJ = true
	# Fin de niveau
	elif $Sprite.animation == 'Winner':
		$SpecialCoin.stop()
		var zic = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/Music')
		zic.stop()

		get_tree().paused = false
		resetAllAliens()
		timer.start(Constants.BOT_TIMER)
		Constants.reTimer = false
		Constants.nbRobot = 0
		get_parent().pause_mode = Node.PAUSE_MODE_INHERIT
		OS.delay_msec(2000)
		get_tree().change_scene('res://Scenes/Result.tscn')
		Constants.dontMoveEnemy = false
		Constants.bonusFireBombs = 0
		# Vide le tableau de backup
		animBackup={}
		Constants.deadOrWinerBJ = true

func _on_timer_timeout():
	$'/root/Game/Levels/timerPB'.queue_free()
	var timerPB = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/timerOutPB')
	if timerPB != null:
		timerPB.queue_free()
	# Active le clignotement des bonus
	var timer = Timer.new()
	timer.connect('timeout',self,'blinkBonus') 
	timer.name='timerBlink'
	get_node('/root/Game/Levels').add_child(timer)
	timer.start(0.2)
	Constants.powerballActive = false
#	Constants.fireBombs = 0
