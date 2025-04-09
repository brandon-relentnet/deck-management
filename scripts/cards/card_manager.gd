extends Node2D
# This simplified CardManager now acts as a coordinator between the specialized handlers

# References to other handlers
var drag_handler: Node2D
var play_handler: Node2D

func _ready() -> void:
	# Get references to other handlers - using get_node_or_null for safety
	drag_handler = get_node_or_null("../CardDragHandler")
	play_handler = get_node_or_null("../CardPlayHandler")
	
	# Check for required dependencies
	if not drag_handler:
		push_error("CardDragHandler not found!")
	
	if not play_handler:
		push_error("CardPlayHandler not found!")

# Public method to start dragging a card (forwards to drag handler)
func start_drag(card: Node2D) -> void:
	if drag_handler and drag_handler.has_method("start_drag"):
		drag_handler.start_drag(card)
	else:
		push_error("Cannot start drag - drag handler not found or missing method!")

# Connect signals from newly created cards to the appropriate handlers
func connect_card_signals(card: Node2D) -> void:
	# Directly connect signals here in the card manager
	if card.has_signal("hovered") and card.has_signal("hovered_off"):
		# First disconnect any existing connections to avoid duplicates
		if card.is_connected("hovered", Callable(self, "_on_card_hovered")):
			card.disconnect("hovered", Callable(self, "_on_card_hovered"))
			
		if card.is_connected("hovered_off", Callable(self, "_on_card_hovered_off")):
			card.disconnect("hovered_off", Callable(self, "_on_card_hovered_off"))
			
		# Now connect the signals
		card.connect("hovered", _on_card_hovered)
		card.connect("hovered_off", _on_card_hovered_off)

# Handler functions for card signals
func _on_card_hovered(card: Node2D) -> void:
	if drag_handler and drag_handler.has_method("on_hovered_over_card"):
		drag_handler.on_hovered_over_card(card)

func _on_card_hovered_off(card: Node2D) -> void:
	if drag_handler and drag_handler.has_method("on_hovered_off_card"):
		drag_handler.on_hovered_off_card(card)

# Handle ending the player's turn (forwards to play handler)
func _on_turn_manager_pressed() -> void:
	if play_handler and play_handler.has_method("end_turn"):
		play_handler.end_turn()
	else:
		push_error("Cannot end turn - play handler not found or missing method!")
