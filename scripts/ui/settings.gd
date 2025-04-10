extends CanvasLayer

@onready var back_button = $BackButton

func _ready() -> void:
	# Connect the button's pressed signal
	back_button.pressed.connect(_on_back_button_pressed)
	
func _on_back_button_pressed():
	await TransitionManager.change_scene("res://scenes/main_menu.tscn")

# Add this to handle the escape key as well
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_back_button_pressed()
