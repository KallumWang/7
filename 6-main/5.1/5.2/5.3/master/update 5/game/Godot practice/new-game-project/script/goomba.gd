extends Area2D


func _on_body_entered(body):
	if body.name == "Player":
		body.respawn()


func _on_head_area_body_entered(body):
	if body.name == "Player" and body.velocity.y > 0:
		body.velocity.y = -600 #this is the bounce
		queue_free() #kills the enemey
