extends CharacterBody2D

# Movement constants
const WALK_SPEED := 350.0
const SPRINT_SPEED := 600.0
const JUMP_VELOCITY := -420.0
const JUMP_PAD_HEIGHT := -600.0
const COYOTE_TIME := 0.15
const JUMP_BUFFER_TIME := 0.15
const DASH_SPEED := 900.0
const DASH_DURATION := 0.2
const MAX_JUMPS := 2

# Stamina constants
const MAX_STAMINA := 100.0
const STAMINA_DRAIN_RATE := 500.0  # per second
const STAMINA_RECOVERY_RATE := 20.0  # per second
const STAMINA_LOW_THRESHOLD := 25.0  # color change threshold

# Variables
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var jump_count := 0
var can_dash := true
var is_dashing := false
var dash_timer := 0.0
var dash_direction := 0
var stamina := MAX_STAMINA
var start_pos := Vector2(63, 444)
var was_on_floor := false   # 👈 track landing

# Node references
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var cam := $Camera2D

func apply_jump_pad():
	velocity.y = JUMP_PAD_HEIGHT

func respawn():
	position = start_pos
	velocity = Vector2.ZERO
	can_dash = true
	is_dashing = false
	jump_count = 0
	stamina = MAX_STAMINA

func _physics_process(delta):
	var on_floor := is_on_floor()

	# Coyote time handling
	if on_floor:
		coyote_timer = COYOTE_TIME
		jump_count = 0
		can_dash = true
	else:
		coyote_timer -= delta

	# Jump buffering
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	jump_buffer_timer -= delta

	# Jumping
	if jump_buffer_timer > 0:
		if coyote_timer > 0 or jump_count < MAX_JUMPS:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0.0

			if coyote_timer > 0:
				jump_count = 1
			else:
				jump_count += 1

			# Play jump animation
			anim.play("jump")
			AudioManager.play("res://sfx/grass_hopper_jump.wav")   # Jump SFX here

	# Dashing
	if Input.is_action_just_pressed("dash") and not on_floor and can_dash:
		is_dashing = true
		can_dash = false
		dash_timer = DASH_DURATION
		var input_dir = Input.get_axis("ui_left", "ui_right")
		dash_direction = sign(input_dir) if input_dir != 0 else (-1 if anim.flip_h else 1)
		velocity = Vector2(dash_direction * DASH_SPEED, 0)

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	# Sprinting logic
	var input_dir = Input.get_axis("ui_left", "ui_right")
	var wants_to_sprint = Input.is_action_pressed("sprint")
	var can_sprint = stamina > 0.0
	var sprinting = wants_to_sprint and can_sprint and input_dir != 0

	# Handle stamina consumption
	if sprinting:
		stamina -= STAMINA_DRAIN_RATE * delta
		stamina = max(stamina, 0)
	else:
		stamina += STAMINA_RECOVERY_RATE * delta
		stamina = min(stamina, MAX_STAMINA)

	# Set the movement speed based on sprinting
	var speed = SPRINT_SPEED if sprinting else WALK_SPEED

	# Horizontal movement
	if not is_dashing:
		if input_dir != 0:
			velocity.x = input_dir * speed
			# 👇 play walk or sprint sound depending on state
			if sprinting:
				AudioManager.play("res://sounds/sprint.ogg")   # Sprinting footsteps SFX here
			else:
				AudioManager.play("res://sfx/")     # Walking footsteps SFX here
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	# Gravity
	if not on_floor and not is_dashing:
		velocity.y += gravity * delta

	# Animations
	if on_floor:
		if abs(velocity.x) > 10:
			anim.play("run")
		else:
			anim.play("Idle")

	# Flip character based on movement direction
	if velocity.x < -10:
		anim.flip_h = true
	elif velocity.x > 10:
		anim.flip_h = false

	move_and_slide()

	# 👇 Landing sound (only when first touching ground after falling/jumping)
	if on_floor and not was_on_floor:
		AudioManager.play("res://sounds/land.ogg")   # Landing SFX here

	was_on_floor = on_floor

	# Respawn if falling too far
	if position.y > 2000:
		respawn()
