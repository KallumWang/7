extends Control

func _ready():
	%Play.pressed.connect(play) #accessed as unique name 
	%Quit.pressed.connect(quit_game)
	AudioManager.play("res://sfx/menu.ogg")

func play():
	ScreenTransition.go_to_scene("vn")


func quit_game():
	get_tree().quit()
