extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		body.start_pos = global_position
		print("Checkpoint set at: ", global_position)
