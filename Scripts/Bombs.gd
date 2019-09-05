extends Area2D

func _process(delta):
	pass

func _on_Bomb_animation_finished():
	var bomb=get_child(0)
	var parent=get_parent()
	
	if bomb.animation == 'CatchBonus' or bomb.animation=='Catch':
		remove_child(self)
		queue_free()


