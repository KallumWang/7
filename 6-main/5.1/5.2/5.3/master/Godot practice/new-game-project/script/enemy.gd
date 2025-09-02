extends CharacterBody2D
@onready var tergert=$"../Player"
var speed=250
func _physics_process(delta):
	var direction=(tergert.position-position).normalized()
	velocity= direction * speed 
	look_at(tergert.position)
	move_and_slide()
