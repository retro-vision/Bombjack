extends Node2D

func _draw():
	if Constants.PLAY_SOUND==true:
		$Music.playing=true
	# Fixe le numéro de level
	update_level()
	initTimer()
	# Création de l'oiseau
	createBird()
	
func initTimer():
	# Suprime l'ancien timer si nécessaire
	var timer = get_node('/root/Game/Levels/Level'+str(Constants.level)+'/timer')
	if timer != null:
		timer.queue_free()
	# Créé le nouveau timer des robots
	timer = Timer.new()
	timer.connect('timeout',self,'_on_timer_timeout') 
	timer.name='timer'
	get_node('/root/Game/Levels/Level'+str(Constants.level)).add_child(timer)
	Constants.reTimer = true
	timer.start(Constants.BOT_TIMER)

func setBotPos():
	match Constants.level:
		1: Constants.botInitPos = Vector2(180,170)
		2: Constants.botInitPos = Vector2(96,144)
		3: Constants.botInitPos = Vector2(200,100)
		4: Constants.botInitPos = Vector2(150,100)
		5: Constants.botInitPos = Vector2(150,100)
		6: Constants.botInitPos = Vector2(120,160)
		7: Constants.botInitPos = Vector2(190,200)
		8: Constants.botInitPos = Vector2(156,120)
		9: Constants.botInitPos = Vector2(170,120)
		10: Constants.botInitPos = Vector2(160,160)
		11: Constants.botInitPos = Vector2(200,80)
		12: Constants.botInitPos = Vector2(120,160)
		
func createBird():
	var birdScene=preload('res://Scenes/Bird.tscn')
	# Instancie l'oiseau 
	var bird=birdScene.instance()
#		bird.position=Vector2(90,500)
	$'/root/Game/Aliens'.add_child(bird)
	bird.get_node('Sprite').play('Profil')
	Constants.deadBird = false

# Called when the node enters the scene tree for the first time.
func _init():
	# Fixe la position du robot en fonction du niveau pour demmarer sur une plateforme
	setBotPos()

func _on_timer_timeout():
	if Constants.reTimer == true:
		var botScene=preload('res://Scenes/Bot.tscn')
		var timer=get_node('/root/Game/Levels/Level'+str(Constants.level)+'/timer')
		# Instancie le robot
		var bot=botScene.instance()
		bot.global_position=Constants.botInitPos
		bot.name='Bot'+str(Constants.nbRobot)
		$'/root/Game/Aliens'.add_child(bot)
		bot.get_node('Sprite').play('Appear')
		timer.stop()
		Constants.reTimer=false
	
func update_level():
	var num_level=get_node('/root/Game/CanvasLayer/Level')
	if num_level!=null:
		num_level.set_text('%02d'%(Constants.level)) # Formate le numéro de level
	
func _input(event):
	# Retour au menu
	if(Input.is_action_just_released('ui_cancel')):
		get_tree().change_scene('res://Scenes/Menu.tscn')
		
