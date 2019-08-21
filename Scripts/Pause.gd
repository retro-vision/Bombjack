extends Control

func _ready():
	get_tree().paused=true

func _input(event):
	if event.is_action_pressed('ui_pause'):
		var new_pause_state = not get_tree().paused
		get_tree().paused=new_pause_state
		visible = new_pause_state
	if event.is_action_pressed('ui_cancel'):
		get_tree().quit()
