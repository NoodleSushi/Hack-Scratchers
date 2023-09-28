extends Node2D

var damage : int = 1
var speed : float = 512

func _process(delta):
	position.y -= delta*speed
	if !$VisibilityNotifier2D.is_on_screen():
		if $Timer.is_stopped():
			$Timer.start()
	else:
		if !$Timer.is_stopped():
			$Timer.stop()


func _on_Timer_timeout():
	queue_free()
	#free()


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player") && !is_queued_for_deletion():
		body.emit_signal("hit_by_obstacle",self,damage)
