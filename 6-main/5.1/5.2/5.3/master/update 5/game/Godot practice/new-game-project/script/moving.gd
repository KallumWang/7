extends Node2D

@onready var path_follow : PathFollow2D = $Path2D/PathFollow2D
@export var speed = 100  # Speed in pixels per second

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Update progress along the path
	path_follow.progress += speed * delta / path_follow.path_length

	# Ensure progress stays between 0 and 1
	if path_follow.progress > 1:
		path_follow.progress = 0  # Reset progress to loop back to start

func _on_body_entered(body):
	if body.name == "Player":
		body.respawn()  # Ensure that the respawn method exists on the player
