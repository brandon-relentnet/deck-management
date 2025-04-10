extends CanvasLayer

const DECK_SYSTEM_SCENE = "res://deck_system.tscn"
const SETTINGS_SCENE = "res://scenes/settings.tscn"
const ANIMATION_DURATION = Utils.DEFAULT_ANIMATION_SPEED

func _ready():
	# Get references to buttons
	var play_button = $MarginContainer/VBoxContainer/PlayButton
	var options_button = $MarginContainer/VBoxContainer/SettingsButton
	var quit_button = $MarginContainer/VBoxContainer/QuitButton
	
	# Connect button signals
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Optional: Add a subtle animation to the menu
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property($MarginContainer/VBoxContainer, "modulate:a", 1.0, 0.5).from(0.0)

func _on_play_pressed():
	# Disable the button to prevent multiple clicks
	$MarginContainer/VBoxContainer/PlayButton.disabled = true
	
	# Use the TransitionManager to transition to the deck system scene
	await TransitionManager.change_scene(DECK_SYSTEM_SCENE)
	
	GameManager.start_game.emit()
	
	print("Transition to deck system complete")
	
func _on_settings_pressed():
	# Disable the button to prevent multiple clicks
	$MarginContainer/VBoxContainer/SettingsButton.disabled = true
	
	# Use the TransitionManager to transition to the settings scene
	await TransitionManager.change_scene(SETTINGS_SCENE)
	
	#GameManager.start_game.emit()

	
func _on_quit_pressed():
	# Quit the game
	get_tree().quit()
