extends Control
class_name DialogueUI

# This signal tells other scripts that the button was pressed.
@warning_ignore("unused_signal")
signal next_pressed

@onready var dialogue_line: RichTextLabel = $"Dialogue box/DialogueLine"
@onready var speaker_label: Label = $"speaker box/SpeakerLabel"
@onready var next_button: TextureButton = $"next_button"

func _ready():
	pass

# This function is called when the TextureButton is pressed.
func _on_next_button_pressed():
	print("Triangle button clicked")
	# Emit the custom signal to be received by the VN script.
	emit_signal("next_pressed")
