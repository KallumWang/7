extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -370

var start_pos = Vector2(63, 444)  # Starting position of the character

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
const COYOTE_TIME = 0.15
const JUMP_BUFFER_TIME = 0.15

var coyote_timer = 0.0
var jump_buffer_timer = 0.0


func respawn():
	position = start_pos
	velocity = Vector2.ZERO  # Optional: clears velocity when respawnin



@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		coyote_timer -= delta
	else:
		coyote_timer = COYOTE_TIME  # Reset when on floor

	# Track jump buffer
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = JUMP_BUFFER_TIME

	jump_buffer_timer -= delta

	# Check if we can jump using coyote time and jump buffer
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0  # Clear buffer so it doesn’t jump again
		anim.play("jump")

	# Animation handling
	if is_on_floor():
		if abs(velocity.x) > 10:
			anim.play("run")
		else:
			anim.play("Idle")

	if velocity.x < -10:
		anim.flip_h = true
	elif velocity.x > 10:
		anim.flip_h = false

	# Get input direction and apply movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Respawn if fallen
	if position.y > 5000:
		respawn()
