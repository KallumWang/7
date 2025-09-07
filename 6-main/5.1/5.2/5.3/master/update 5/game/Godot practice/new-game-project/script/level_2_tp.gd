extends Area2D



func _on_body_entered(body):
	if body.name == "Player":
		ScreenTransition.go_to_scene("res://rhythm game stuff/levels/game_level.tscn")
