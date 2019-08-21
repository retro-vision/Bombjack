extends Node2D

const MAX_POWERBALL = 10 # Nombre avant l'apparition de la powerball
const MAX_RAND_BONUS = 20
const MAX_TYPE_BONUS = 2

func _draw():
	createPlayer()
	# Instancie le niveau
	print('Load level: ', Constants.level)
	var levelStr = 'res://Scenes/Level'+str(Constants.level)+'.tscn'
	var level = load(levelStr).instance()
	level.name = 'Level'+str(Constants.level)
	$Levels.add_child(level)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Supprime d'éventuels niveaux
	for item in $Levels.get_children():
		item.queue_free()
	# Positionne le bonus à 1 pour commencer
	Constants.bonusFactor=1
	# Créé le timer pour faire apparaitre les bonus
	var timer = Timer.new()
	timer.connect('timeout',self,'_on_timer_timeoutBonus') 
	timer.name='timerOutBonus'
	get_node('/root/Game/Levels/').add_child(timer)
	timer.start(5)

	
func createPlayer():
#	if Constants.deadOrWinerBJ == true:
		var node = get_node('/root/Game/Player')
		if Constants.deadOrWinerBJ == true:
			remove_child($'/root/Game/Player')

			var player = preload('res://Scenes/Player.tscn').instance()
			if player !=  null:
				player.name='Player'
				$'/root/Game'.add_child(player)
				Constants.deadOrWinerBJ = false

func _process(delta):
	createPlayer()
	# Effacte les autres chiffres de bonus
	for item in $CanvasLayer/Bonus.get_children():
		item.hide()

	# Affiche le bon multiplicateur de bonus
	match Constants.bonusFactor:
		1:
			$CanvasLayer/Bonus/Factor1.show()
		2:
			$CanvasLayer/Bonus/Factor2.show()
		3:
			$CanvasLayer/Bonus/Factor3.show()
		4:
			$CanvasLayer/Bonus/Factor4.show()
		5:
			$CanvasLayer/Bonus/Factor5.show()
	
	# Gestion de la powerball
#	if Constants.fireBombs > MAX_POWERBALL:
#		Constants.fireBombs = 0
	if Constants.powerballPoint >= MAX_POWERBALL and Constants.powerballActive == false:
		# Créé et affiche la powerball
		print('Create PowerBall')
		var powerBall = preload('res://Scenes/PowerBallP.tscn').instance()
		if $'/root/Game/Bonus/PowerBallP' == null:
			$'/root/Game/Bonus'.add_child(powerBall)
#		Constants.powerballPoint = 0
#		Constants.powerballActive = true
#		Constants.fireBombs = 0
		# Timer de la Powerball. Elle disparait après 10 secondes
			var timer = Timer.new()
			timer.connect('timeout',self,'_on_timer_timeoutPB') 
			timer.name='timerOutPB'
			get_node('/root/Game/Levels/Level'+str(Constants.level)).add_child(timer)
			timer.start(10)

func _on_timer_timeoutPB():
	var pb = get_node('/root/Game/Bonus/PowerBallP')
	if pb != null:
		pb.queue_free()
	# Reset la powerball et le nombre de firebomb attrapées
	Constants.powerballActive = false
	Constants.bonusFireBombs = 0
	Constants.powerballPoint = 0
	Constants.powerballPoint = 0.0
#	Constants.fireBombs = 0
	var timer = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/timerOutPB')
	timer.queue_free() 
	
func _on_timer_timeoutBonus():
	var appear = randi()%MAX_RAND_BONUS
	var bonusType = randi()%MAX_TYPE_BONUS
#	print('Bonus appear factor: ', appear)
#	print('Bonus type: ', bonusType)
	if appear == 7:
		# instancie les bonus
		if bonusType == 0:
			# Bonus E
			print('Creation du bonus E')
			var bonus = preload('res://Scenes/BonusE.tscn').instance()
			if $'/root/Game/Bonus/BonusE' == null:
				$'/root/Game/Bonus'.add_child(bonus)
		else:
			# Bonus B
			print('Creation du bonus B')
			var bonus = preload('res://Scenes/BonusB.tscn').instance()
			if $'/root/Game/Bonus/BonusB' == null:
				$'/root/Game/Bonus'.add_child(bonus)
