extends CanvasLayer

func _ready():
	# Get references to buttons
	var play_button = $MarginContainer/VBoxContainer/PlayButton
	var options_button = $MarginContainer/VBoxContainer/OptionsButton
	var quit_button = $MarginContainer/VBoxContainer/QuitButton
	
	# Connect button signals
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Optional: Add a subtle animation to the menu
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property($MarginContainer/VBoxContainer, "modulate:a", 1.0, 0.5).from(0.0)

func _on_play_pressed():
	# Change to the main game scene
	get_tree().change_scene_to_file("res://deck_system.tscn")
	
func _on_options_pressed():
	# For now, just print a message
	print("Options menu (not implemented)")
	# Load an options menu scene here in the future
	
func _on_quit_pressed():
	# Quit the game
	get_tree().quit()
