extends Node2D

# Signals emitted when mouse enters or leaves the card area
signal hovered(card)      # Sent when mouse enters card area
signal hovered_off(card)  # Sent when mouse exits card area

# Stores the card's position in the player's hand for animation purposes
var hand_position: Vector2

# Called when the node enters the scene tree
func _ready() -> void:
	# Register this card with the card manager to handle signals
	get_parent().connect_card_signals(self)

# Called when the mouse enters the card's collision area
func _on_area_2d_mouse_entered() -> void:
	# Let the card manager know this card is being hovered over
	emit_signal("hovered", self)

# Called when the mouse exits the card's collision area
func _on_area_2d_mouse_exited() -> void:
	# Let the card manager know the mouse is no longer hovering over this card
	emit_signal("hovered_off", self)
