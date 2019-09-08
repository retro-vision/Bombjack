extends LineEdit

const MAX_SCORE = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	# Supprime l'ancien nom
	clear()
	grab_focus()
	
func printHiScore():
	print('AFFICHE SCORES')
	print('==============')
	var list = range(MAX_SCORE)
	list.invert()
	for item in list:
		print(Constants.hiScores[item][0]," ", Constants.hiScores[item][1]," ",Constants.hiScores[item][2])
	
func addScore():
	var namePlayer = get_text()
	var list = range(MAX_SCORE)
#	list.invert()
	print('Ajout score')
	print(Constants.hiScores)
	for item in list:
		if Constants.score > Constants.hiScores[item][0]:
			# Décale le reste des scores
			var list2 = range(item, MAX_SCORE-1)
#			var itemBKP = item
			list2.invert()
			print('Liste2 ', list2)
			print('Item ', item)
			for item2 in list2:
				# Score
				Constants.hiScores[item2+1][0] = Constants.hiScores[item2][0]
				# Name
				Constants.hiScores[item2+1][1] = Constants.hiScores[item2][1]
				# Level
				Constants.hiScores[item2+1][2] = Constants.hiScores[item2][2]
			# Insert le score
			# Score
			Constants.hiScores[item][0] = Constants.score
			# Name
			Constants.hiScores[item][1] = namePlayer
			# Level
			Constants.hiScores[item][2] = Constants.level
			break
	print(Constants.hiScores)

func saveScore():
	print('Ecrit les nouveau scores')

	var file = File.new()
	file.open(Constants.FILE_NAME_SCORES, File.WRITE)
	for item in range(MAX_SCORE):
		# Choisi un nom aléatoirement dans le tableau
		# Score
		file.store_32(Constants.hiScores[item][0])
		# Name
		file.store_line(Constants.hiScores[item][1])
		# Level
		file.store_8(Constants.hiScores[item][2])
		print(item, ' ',Constants.hiScores[item][0], ' ' ,Constants.hiScores[item][1], ' ',Constants.hiScores[item][2])
	file.close()
	OS.delay_msec(500)

func _process(delta):
	var namePlayer = get_text()
	if namePlayer.length() > 0:
		if(Input.is_action_just_pressed('ui_accept')):
			# Ajoute le nom dans le tableau des scores
			addScore()
			# Sauve les scores
			saveScore()
			# Fait apparaitre les scores
			Constants.putScore = true
			get_tree().change_scene('res://Scenes/Menu.tscn')
