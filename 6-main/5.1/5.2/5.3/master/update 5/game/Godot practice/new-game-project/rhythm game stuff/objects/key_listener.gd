extends Sprite2D

@onready var falling_key = preload("res://rhythm game stuff/objects/falling_key.tscn")
@onready var score_text = preload("res://rhythm game stuff/objects/score_press_text.tscn")
@export var key_name: String = ""

var falling_key_queue: Array[Node] = []

# Scoring thresholds
var perfect_press_threshold: float = 230
var great_press_threshold: float = 250
var good_press_threshold: float = 260
var ok_press_threshold: float = 280

var perfect_press_score: float = 250
var great_press_score: float = 100
var good_press_score: float = 50
var ok_press_score: float = 20

func _ready():
	$GlowOverlay.frame = frame + 4
	Signals.CreateFallingKey.connect(CreateFallingKey)

@warning_ignore("unused_parameter")
func _process(delta):
	if Input.is_action_just_pressed(key_name):
		Signals.KeyListenerPress.emit(key_name, frame)

	# Make sure there is a falling key to check for
	while falling_key_queue.size() > 0:
		var front_key = falling_key_queue.front()

		# ✅ Check if the node is still in the scene tree (has not been freed)
		if !is_instance_valid(front_key):
			falling_key_queue.pop_front()
			continue  # skip to next key

		# If the key has passed, it's a miss
		if front_key.has_passed:
			falling_key_queue.pop_front()
			_show_score_text("MISS")
			Signals.ResetCombo.emit()
			return  # prevent further input handling this frame

		# If key is pressed, check distance from pass line
		if Input.is_action_just_pressed(key_name):
			var key_to_pop = falling_key_queue.pop_front()

			if !is_instance_valid(key_to_pop):
				return  # already freed somehow

			var distance_from_pass = abs(key_to_pop.pass_threshold - key_to_pop.global_position.y)

			$AnimationPlayer.stop()
			$AnimationPlayer.play("key_hit")

			var press_score_text: String = ""

			if distance_from_pass < perfect_press_threshold:
				Signals.IncrementScore.emit(perfect_press_score)
				press_score_text = "PERFECT"
				Signals.IncrementCombo.emit()
			elif distance_from_pass < great_press_threshold:
				Signals.IncrementScore.emit(great_press_score)
				press_score_text = "GREAT"
				Signals.IncrementCombo.emit()
			elif distance_from_pass < good_press_threshold:
				Signals.IncrementScore.emit(good_press_score)
				press_score_text = "GOOD"
				Signals.IncrementCombo.emit()
			elif distance_from_pass < ok_press_threshold:
				Signals.IncrementScore.emit(ok_press_score)
				press_score_text = "OK"
				Signals.IncrementCombo.emit()
			else:
				press_score_text = "MISS"
				Signals.ResetCombo.emit()

			key_to_pop.queue_free()
			_show_score_text(press_score_text)
			return

		break  # if no key pressed, don't continue checking queue

func CreateFallingKey(button_name: String):
	if button_name == key_name:
		var fk_inst = falling_key.instantiate()
		get_tree().get_root().call_deferred("add_child", fk_inst)
		fk_inst.Setup(position.x, frame + 4)

		falling_key_queue.push_back(fk_inst)

func _on_random_spawn_timer_timeout():
	$RandomSpawnTimer.wait_time = randf_range(0.4, 3)
	$RandomSpawnTimer.start()

func _show_score_text(text: String):
	var st_inst = score_text.instantiate()
	get_tree().get_root().call_deferred("add_child", st_inst)
	st_inst.SetTextInfo(text)
	st_inst.global_position = global_position + Vector2(0, -20)
