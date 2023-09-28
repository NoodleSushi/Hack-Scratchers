extends Area2D



func _on_Spike_body_entered(body):
	var main = $"../.."
	if body.is_in_group("Player") && main.spikes_rise:
		body.emit_signal("hit_by_obstacle",self,0)
