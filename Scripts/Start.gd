extends Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused=true
	get_parent().pause_mode=Node.PAUSE_MODE_INHERIT

	$AnimationPlayer.play('Start')

func _on_AnimationPlayer_animation_finished(anim_name):
	OS.delay_msec(1000)
	queue_free()
	get_tree().paused=false
	get_parent().pause_mode=Node.PAUSE_MODE_INHERIT
	$'/root/Game/CanvasLayer/Start'.queue_free()
