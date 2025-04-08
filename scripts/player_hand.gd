extends Node2D

# Constants for hand layout and animation
const CARD_WIDTH = 170                # Horizontal spacing between cards in hand
const HAND_Y_POSITION = 890           # Vertical position of the player's hand
const DEFAULT_CARD_MOVE_SPEED = 0.1   # Default speed for card movement animations

# State variables
var player_hand: Array = []           # Array of cards currently in the player's hand
var center_screen_x: float            # Horizontal center of the screen (calculated at startup)

# Called when the node enters the scene tree
func _ready() -> void:
	# Cache the horizontal center of the screen
	center_screen_x = get_viewport().size.x / 2

# Adds a card to the player's hand or updates its position if it's already in hand
func add_card_to_hand(card: Node2D, speed: float) -> void:
	if card not in player_hand:
		# Add new card to the beginning of the hand
		player_hand.insert(0, card)
		# Recalculate all card positions
		update_hand_positions(speed)
	else:
		# If the card is already in hand, just move it to its saved position
		animate_card_to_position_with_effects(card, card.hand_position, DEFAULT_CARD_MOVE_SPEED)

# Enhanced version of add_card_to_hand with visual effects
func add_card_to_hand_with_effects(card: Node2D, speed: float) -> void:
	if card not in player_hand:
		# Add new card to the beginning of the hand
		player_hand.insert(0, card)
		# Recalculate all card positions
		update_hand_positions_with_effects(speed)
	else:
		# If the card is already in hand, move it to its saved position with effects
		animate_card_to_position_with_effects(card, card.hand_position, speed)
	
# Updates positions of all cards in hand based on current hand size
func update_hand_positions(speed: float) -> void:
	for i in range(player_hand.size()):
		var card = player_hand[i]
		# Calculate new position for this card based on its index
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		# Store the position on the card for later reference
		card.hand_position = new_position
		# Animate the card moving to its new position
		animate_card_to_position_with_effects(card, new_position, speed)

# Enhanced version with effects for all cards
func update_hand_positions_with_effects(speed: float) -> void:
	for i in range(player_hand.size()):
		var card = player_hand[i]
		# Calculate new position for this card based on its index
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		# Store the position on the card for later reference
		card.hand_position = new_position
		# Animate the card moving to its new position with effects
		animate_card_to_position_with_effects(card, new_position, speed)
		
# Calculates the x-coordinate for a card based on its index in the hand
func calculate_card_position(index: int) -> float:
	var card_count = player_hand.size()
	# Calculate total width of cards to center the hand
	var x_offset = (card_count - 1) * CARD_WIDTH
	# Return position that centers the entire hand on screen
	return center_screen_x + index * CARD_WIDTH - x_offset / 2

# Enhanced animation with effects
func animate_card_to_position_with_effects(card: Node2D, new_position: Vector2, speed: float) -> void:
	var tween = create_tween()
	
	# Set better easing for more natural movement
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Move the card to its position
	tween.tween_property(card, "position", new_position, speed)
	
	# Animate the card's rotation to 0 (cards might start rotated)
	tween.parallel().tween_property(card, "rotation_degrees", 0, speed)
	
	# Scale animation - growing to normal size
	tween.parallel().tween_property(card, "scale", Vector2(1, 1), speed)
	
	# Fade in animation
	tween.parallel().tween_property(card, "modulate:a", 1.0, speed * 0.8)
	
	# Add a subtle bounce at the end
	tween.tween_property(card, "position:y", new_position.y - 10, speed * 0.2)
	tween.tween_property(card, "position:y", new_position.y, speed * 0.15)

# Removes a card from the hand and updates the positions of remaining cards
func remove_card_from_hand(card: Node2D) -> void:
	if card in player_hand:
		player_hand.erase(card)
		# Recalculate positions for all remaining cards
		update_hand_positions_with_effects(DEFAULT_CARD_MOVE_SPEED)
		
func clear_hand() -> void:
	player_hand.clear()
