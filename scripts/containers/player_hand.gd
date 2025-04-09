extends Node2D

# Constants for hand layout and animation
const CARD_WIDTH = 170
const HAND_Y_POSITION = 890
const DEFAULT_CARD_MOVE_SPEED = Utils.DEFAULT_ANIMATION_SPEED

# State variables
var player_hand: Array = []
var center_screen_x: float

# Called when the node enters the scene tree
func _ready() -> void:
	# Cache the horizontal center of the screen
	center_screen_x = get_viewport().size.x / 2

# Adds a card to the player's hand
func add_card_to_hand(card: Node2D, speed: float) -> void:
	if card not in player_hand:
		# Add new card to the beginning of the hand
		player_hand.insert(0, card)
		# Recalculate all card positions
		update_hand_positions(speed)
	else:
		# If the card is already in hand, just move it directly to its saved position
		# without changing its position in the array or recalculating positions
		animate_card_to_position(card, card.hand_position, speed)

# Enhanced version of add_card_to_hand with visual effects
func add_card_to_hand_with_effects(card: Node2D, speed: float) -> void:
	add_card_to_hand(card, speed)
	
# Updates positions of all cards in hand based on current hand size
func update_hand_positions(speed: float) -> void:
	for i in range(player_hand.size()):
		var card = player_hand[i]
		# Calculate new position for this card based on its index
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		# Store the position on the card for later reference
		card.hand_position = new_position
		# Animate the card moving to its new position
		animate_card_to_position(card, new_position, speed)
		
# Calculates the x-coordinate for a card based on its index in the hand
func calculate_card_position(index: int) -> float:
	var card_count = player_hand.size()
	# Calculate total width of cards to center the hand
	var x_offset = (card_count - 1) * CARD_WIDTH
	# Return position that centers the entire hand on screen
	return center_screen_x + index * CARD_WIDTH - x_offset / 2

# Animate a card to a position with additional effects specific to cards in hand
func animate_card_to_position(card: Node2D, new_position: Vector2, speed: float) -> void:
	# Use the utility function for basic animation
	Utils.animate_node_with_effects(card, new_position, speed)
	
	# Add hand-specific bounce effect
	var tween = card.create_tween()
	tween.tween_property(card, "position:y", new_position.y - 10, speed * 0.2)
	tween.tween_property(card, "position:y", new_position.y, speed * 0.15)

# Removes a card from the hand and updates the positions of remaining cards
func remove_card_from_hand(card: Node2D) -> void:
	if card in player_hand:
		player_hand.erase(card)
		# Recalculate positions for all remaining cards
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
		
# Clears all cards from the hand
func clear_hand() -> void:
	player_hand.clear()
