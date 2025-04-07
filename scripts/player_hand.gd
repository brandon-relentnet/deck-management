extends Node2D

# Constants for hand layout and animation
const CARD_WIDTH = 100                # Horizontal spacing between cards in hand
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
		animate_card_to_position(card, card.hand_position, DEFAULT_CARD_MOVE_SPEED)
	
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

# Creates a tween to smoothly move a card to a new position
func animate_card_to_position(card: Node2D, new_position: Vector2, speed: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

# Removes a card from the hand and updates the positions of remaining cards
func remove_card_from_hand(card: Node2D) -> void:
	if card in player_hand:
		player_hand.erase(card)
		# Recalculate positions for all remaining cards
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
