extends CharacterBody2D


const SPEED = 350.0
const JUMP_VELOCITY = -392
var jump_pad_height := -600  # Negative because Y increases downward in Godot

func apply_jump_pad():
	velocity.y = jump_pad_height
var jump_count = 0

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
	#print(jump_count)
	#print(jump_buffer_timer)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		coyote_timer -= delta
	else:
		coyote_timer = COYOTE_TIME  # Reset when on floor
		jump_count = 0

	# Track jump buffer
	if Input.is_action_just_pressed("ui_accept") and jump_count < 2:
		jump_count += 1
		jump_buffer_timer = JUMP_BUFFER_TIME
		velocity.y = JUMP_VELOCITY
		anim.play("jump")
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
