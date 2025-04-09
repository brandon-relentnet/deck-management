# Add this script to your Main node in main.tscn
extends Node2D

func _ready():
	# Initialize the game
	setup_game()
	
	# Add a back button to return to main menu
	create_back_button()

func setup_game():
	# Initialize game state based on GameManager settings
	# For example, you might load a specific deck based on settings
	print("Starting game at level: ", GameManager.current_level)
	
	# Optional: Dramatic entrance animation
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	# Find and animate your game elements
	var deck = $Deck
	var discard = $Discard
	var hand = $PlayerHand
	
	# Example animation: Cards flying in from off-screen
	tween.tween_property(deck, "position", deck.position, 0.5).from(Vector2(deck.position.x - 200, deck.position.y))
	tween.tween_property(discard, "position", discard.position, 0.5).from(Vector2(discard.position.x + 200, discard.position.y))

func create_back_button():
	# Create a button to return to main menu
	var back_button = Button.new()
	back_button.text = "Main Menu"
	back_button.position = Vector2(50, 50)
	back_button.size = Vector2(150, 50)
	
	# Create a canvas layer to ensure the button is visible above the game
	var canvas = CanvasLayer.new()
	add_child(canvas)
	canvas.add_child(back_button)
	
	# Connect the button's pressed signal
	back_button.pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed():
	# Ask for confirmation before quitting
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.title = "Return to Main Menu"
	confirm_dialog.dialog_text = "Are you sure you want to quit this game and return to the main menu?"
	confirm_dialog.get_ok_button().text = "Yes"
	confirm_dialog.get_cancel_button().text = "No"
	
	# Add the dialog to the scene
	add_child(confirm_dialog)
	
	# Connect dialog signals
	confirm_dialog.confirmed.connect(_confirm_return_to_menu)
	
	# Show the dialog
	confirm_dialog.popup_centered()

func _confirm_return_to_menu():
	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# Add this to handle the escape key as well
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_back_button_pressed()
