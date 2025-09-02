extends CanvasLayer

@export var switch_duration: float = 1.0
var current_scene: String = ''

func _init():
	var regex = RegEx.new()
	regex.compile('res://scenes/([^\\.]+)')
	var result = regex.search(
		ProjectSettings.get('application/run/main_scene'))
	current_scene = result.get_string(1)

func _ready():
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$ColorRect.modulate.a = 0  # Fully transparent

func go_to_scene(scene: String, awaitable = null):
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP

	# Fade to black
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(
		$ColorRect, 'modulate:a', 1, switch_duration / 2.0)
	await tween.finished

	# Change scene
	get_tree().change_scene_to_file(
		"res://scenes/%s.tscn" % scene)
	get_tree().paused = false
	if awaitable:
		current_scene = scene

	# Optional: Wait a short moment before fading back in
	await get_tree().create_timer(0.1).timeout

	# Fade from black
	var tween2 = get_tree().create_tween()
	tween2.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween2.tween_property(
		$ColorRect, 'modulate:a', 0, switch_duration / 2.0)

	await tween2.finished
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
