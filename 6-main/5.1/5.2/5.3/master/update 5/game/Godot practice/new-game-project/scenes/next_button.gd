extends Area2D

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("✅ Triangle clicked!")
