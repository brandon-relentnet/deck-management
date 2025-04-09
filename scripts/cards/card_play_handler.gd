extends Node2D
class_name CardPlayHandler

# Constants
const DEFAULT_CARD_MOVE_SPEED = Utils.DEFAULT_ANIMATION_SPEED
const DISCARD_PILE_POSITION = Vector2(1770, 890)

# Signal for when a card is successfully played
signal card_played(card)
signal card_discarded(card)

# References to other systems
var player_hand: Node2D
var turn_manager: Node
var discard_pile: Node2D
var deck: Node2D

func _ready() -> void:
	# Get references to required nodes
	player_hand = $"../PlayerHand"
	turn_manager = $"../TurnManager"
	discard_pile = $"../Discard"
	deck = $"../Deck"

# Attempts to play a card in a slot
# Returns true if successful, false otherwise
func try_play_card(card: Node2D, card_slot: Node2D) -> bool:
	# If no valid slot or slot is already occupied, can't play the card
	if not card_slot or card_slot.card_in_slot:
		return false
		
	# Check energy requirements
	var card_energy_cost = card.energy
	if turn_manager.player_energy < card_energy_cost:
		return false
	
	# Create game_state dictionary to pass to CardEffects
	var game_state = {
		"deck": deck,
		"turn_manager": turn_manager,
		"player_hand": player_hand,
		# Add other game state references as needed:
		# "enemy_manager": $"../EnemyManager",
		# "player_stats": $"../PlayerStats",
	}
	
	# Process all card effects using the CardEffects system
	CardEffects.process_card_effects(card, game_state)
	
	# All requirements met, play the card
	player_hand.remove_card_from_hand(card)
	card.position = card_slot.position
	card_slot.played_card = card
	
	# Spend energy
	turn_manager.player_energy -= card_energy_cost
	turn_manager.update_player_energy_label()
	
	# Disable collision to prevent further interaction with placed card
	card.get_node("Area2D/CollisionShape2D").disabled = true
	card_slot.card_in_slot = true
	
	# Immediately set z-index to ensure it's below the discard pile when it moves there
	card.z_index = -5
	
	# Emit signal that card was played
	emit_signal("card_played", card)
	
	# Move to discard
	move_card_to_discard(card_slot.played_card, DEFAULT_CARD_MOVE_SPEED / 2)
	card_slot.card_in_slot = false
	
	return true

# Move a card to the discard pile
func move_card_to_discard(card: Node2D, speed: float) -> void:
	if !is_instance_valid(card):
		return
		
	# Ensure the card is visually below the discard pile
	card.z_index = -1
		
	Utils.animate_node_with_effects(card, DISCARD_PILE_POSITION, speed)
	
	# Add to discard pile
	discard_pile.discard_pile.append(card.card_id)
	
	# Emit signal that card was discarded
	emit_signal("card_discarded", card)
	
	# Wait for the animation to finish
	await Utils.create_timer(DEFAULT_CARD_MOVE_SPEED / 2)
	
	# Only queue_free after animation completes
	if is_instance_valid(card):
		card.queue_free()
		
	discard_pile.update_discard_display()
	
	if is_instance_valid(card):
		card.z_index = -5

# Discards all cards in the player's hand
func discard_hand() -> void:
	var cards_to_discard = player_hand.player_hand.duplicate()
	cards_to_discard.reverse()
	
	for card in cards_to_discard:
		move_card_to_discard(card, (DEFAULT_CARD_MOVE_SPEED / 2))
		await Utils.create_timer(DEFAULT_CARD_MOVE_SPEED / 2)
	
	player_hand.clear_hand()

# Process end of turn logic
func end_turn() -> void:
	deck.currently_drawing_a_card = true
	
	# Discard current hand if any cards remain
	var player_hand_size = player_hand.player_hand.size()
	if player_hand_size > 0:
		discard_hand()
		await Utils.create_timer((DEFAULT_CARD_MOVE_SPEED / 2) * player_hand_size)
	
	# Draw new hand and reset energy
	deck.draw_hand(deck.CURRENT_HAND_DRAW)
	turn_manager.player_energy = turn_manager.NEW_PLAYER_ENERGY
	turn_manager.update_player_energy_label()
