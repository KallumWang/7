extends Node2D

@onready var dialogue_ui = %DialogueUI
@onready var speaker_label: Label = dialogue_ui.get_node("speaker box/SpeakerLabel")
@onready var dialogue_label: RichTextLabel = dialogue_ui.get_node("Dialogue box/DialogueLine")

const dialog_lines: Array[String] = [
	"Narrator: Hermes was flying through the forest when he was hit by an arrow.",
	"Hermes: Ouch, looks like I've been shot. My legs are okay, but looks like I can't fly for a while."
]

var dialogue_index: int = 0

func _ready():
	if dialogue_ui:
		dialogue_ui.connect("next_pressed", Callable(self, "_on_dialogue_ui_next_pressed"))
	else:
		push_error("DialogueUI node not found")

	if speaker_label and dialogue_label:
		process_line(parse_line(dialog_lines[dialogue_index]))

func parse_line(line: String) -> Dictionary:
	var parts = line.split(":", false)
	var speaker = parts[0].strip_edges()
	var dialogue = ":".join(parts.slice(1)).strip_edges()
	return {
		"speaker_name": speaker,
		"dialogue_line": dialogue
	}

func process_line(line_info: Dictionary) -> void:
	speaker_label.text = line_info["speaker_name"]
	dialogue_label.clear()
	dialogue_label.append_text(line_info["dialogue_line"])

func _on_dialogue_ui_next_pressed():
	print("Advancing dialogue")
	if dialogue_index < dialog_lines.size() - 1:
		dialogue_index += 1
		process_line(parse_line(dialog_lines[dialogue_index]))
	else:
		print("Dialogue finished")
		# Load the path to the next scene.
		@warning_ignore("unused_variable")
		var next_scene_path = "res://level_2_tp.tscn"
		
		# Change the scene.
		get_tree().change_scene_to_file("res://scenes/game.tscn")
