func go_to_scene(scene: String, awaitable = null):
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP

	# Fade to black
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($ColorRect, 'modulate:a', 1, switch_duration / 2.0)
	await tween.finished

	# If `scene` looks like a path, use as-is; else prepend folder + extension
	var scene_path = scene
	if not scene.begins_with("res://"):
		scene_path = "res://rhythm game stuff/levels/%s.tscn" % scene

	get_tree().change_scene_to_file(scene_path)
	get_tree().paused = false
	if awaitable:
		current_scene = scene

	await get_tree().create_timer(0.1).timeout

	# Fade from black
	var tween2 = get_tree().create_tween()
	tween2.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween2.tween_property($ColorRect, 'modulate:a', 0, switch_duration / 2.0)
	await tween2.finished
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
