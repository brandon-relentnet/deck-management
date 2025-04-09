extends Node2D

const DEFAULT_CARD_MOVE_SPEED = 0.1
const DISCARD_PILE_POSITION = Vector2(1770, 890)

# State variables
var card_being_dragged: Node2D = null
var screen_size: Vector2
var is_hovering_on_card: bool = false
var player_hand_reference: Node2D
var turn_manager: Node
var input_manager: Node

# Called when the node enters the scene tree
func _ready() -> void:
	# Cache common references
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	turn_manager = $"../TurnManager"
	input_manager = $"../InputManager"
	
	# Connect to input manager's mouse release signal
	input_manager.connect("left_mouse_button_released", on_left_click_released)

# Called every frame
func _process(_delta: float) -> void:
	if not card_being_dragged:
		return
	
	# Update the dragged card's position to follow the mouse, but stay within screen boundaries
	var mouse_pos = get_global_mouse_position()
	card_being_dragged.position = Vector2(
		clamp(mouse_pos.x, 0, screen_size.x), 
		clamp(mouse_pos.y, 0, screen_size.y)
	)

# Begin dragging a card
func start_drag(card: Node2D) -> void:
	card_being_dragged = card
	card.is_being_dragged = true
	set_card_scale(card, false)

# Finish dragging a card and determine where it should go
func finish_drag() -> void:
	if !is_instance_valid(card_being_dragged):
		card_being_dragged = null
		return
		
	set_card_scale(card_being_dragged, true)
	
	# Check if the card is over a valid card slot
	var card_slot = raycast_check_for_card_slot()
	
	# Try to play the card if conditions are met
	if try_play_card(card_slot):
		# Card was played successfully
		pass
	else:
		# Important: First check if card is already in the hand before returning it
		if card_being_dragged in player_hand_reference.player_hand:
			# If already in hand, just animate it back to its stored position
			Utils.animate_node_with_effects(card_being_dragged, card_being_dragged.hand_position, DEFAULT_CARD_MOVE_SPEED)
		else:
			# Only add to hand if it's not already there
			player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	
	# Reset the card's dragging state before clearing reference
	card_being_dragged.is_being_dragged = false
	card_being_dragged = null

# Attempts to play a card in a slot. Returns true if successful
func try_play_card(card_slot) -> bool:
	# If no valid slot or slot is already occupied, can't play the card
	if not card_slot or card_slot.card_in_slot:
		return false
		
	# Check energy requirements
	var card_energy_cost = card_being_dragged.energy
	if turn_manager.player_energy < card_energy_cost:
		return false
		
	# Access effect amount and effects array from the card
	var card_effects = card_being_dragged.effects
	var card_effect_amount = card_being_dragged.effect_amount
	
	print("card effects: ", card_effects)
	print("effect amount: ", card_effect_amount)
	
	for effect in card_effects:
		match effect:
			"draw_card":
				print("Drawing ", card_effect_amount, " card(s)")
				$"../Deck".draw_hand(card_effect_amount)
		
	# All requirements met, play the card
	player_hand_reference.remove_card_from_hand(card_being_dragged)
	card_being_dragged.position = card_slot.position
	card_slot.played_card = card_being_dragged
	
	# Spend energy
	turn_manager.player_energy -= card_energy_cost
	turn_manager.update_player_energy_label()
	
	# Disable collision to prevent further interaction with placed card
	card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
	card_slot.card_in_slot = true
	
	# Immediately set z-index to ensure it's below the discard pile when it moves there
	card_being_dragged.z_index = -5
	
	# Process card effects and move to discard
	move_card_to_discard(card_slot.played_card)
	card_slot.card_in_slot = false
	
	return true

# Move a card to the discard pile
func move_card_to_discard(card) -> void:
	if !is_instance_valid(card):
		return
		
	# Ensure the card is visually below the discard pile
	card.z_index = -1
		
	Utils.animate_node_with_effects(card, DISCARD_PILE_POSITION, DEFAULT_CARD_MOVE_SPEED)
	
	var discard_pile = $"../Discard"
	# discard_pile.discard_pile.append(card)
	discard_pile.discard_pile.append(card.card_id)
	
	# Wait for the animation to finish
	await Utils.create_timer(DEFAULT_CARD_MOVE_SPEED)
	
	# Only queue_free after animation completes
	if is_instance_valid(card):
		card.queue_free()
		
	discard_pile.update_discard_display()
	
	if is_instance_valid(card):
		card.z_index = -5

# Discards all cards in the player's hand
func move_hand_to_discard() -> void:
	var cards_to_discard = player_hand_reference.player_hand.duplicate()
	cards_to_discard.reverse()
	
	for card in cards_to_discard:
		move_card_to_discard(card)
		await Utils.create_timer(DEFAULT_CARD_MOVE_SPEED)
	
	player_hand_reference.clear_hand()
		
# Connect signals from newly created cards to this manager
func connect_card_signals(card: Node2D) -> void:
	if card.has_signal("hovered") and card.has_signal("hovered_off"):
		card.connect("hovered", on_hovered_over_card)
		card.connect("hovered_off", on_hovered_off_card)

# Handler for mouse button release
func on_left_click_released() -> void:
	if card_being_dragged:
		finish_drag()

# Handler for when the mouse enters a card's area
func on_hovered_over_card(card: Node2D) -> void:
	# Skip hover effects if draw pile view is open
	if input_manager.draw_pile_view_open:
		return
		
	# Only update if we weren't already hovering over a card
	if not is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
	
# Handler for when the mouse exits a card's area
func on_hovered_off_card(card: Node2D) -> void:
	# Skip hover effects if draw pile view is open
	if input_manager.draw_pile_view_open:
		return
		
	# Ignore hover-off events while dragging
	if card_being_dragged:
		return
	
	# Remove highlight from the card we just left
	highlight_card(card, false)
	
	# Check if we immediately entered another card
	var new_card_hovered = raycast_check_for_card()
	
	if new_card_hovered:
		highlight_card(new_card_hovered, true)
	else: 
		is_hovering_on_card = false
	
# Apply or remove visual highlighting from a card
func highlight_card(card: Node2D, hovered: bool) -> void:
	set_card_scale(card, hovered)
	card.z_index = 2 if hovered else 1

# Sets a card's scale based on whether it's highlighted/hovered
func set_card_scale(card: Node2D, is_enlarged: bool) -> void:
	card.scale = Vector2(1.05, 1.05) if is_enlarged else Vector2(1, 1)

# Convenience wrapper for checking for card slots at the current mouse position
func raycast_check_for_card_slot() -> Node2D:
	var result = Utils.raycast_check_for_object(get_world_2d(), get_global_mouse_position(), Utils.CARD_SLOT_COLLISION_MASK)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

# Convenience wrapper for checking for cards at the current mouse position
func raycast_check_for_card() -> Node2D:
	var result = Utils.raycast_check_for_object(get_world_2d(), get_global_mouse_position(), Utils.CARD_COLLISION_MASK)
	if not result or result.size() == 0:
		return null
	
	# If multiple cards are under the cursor, get the one with highest z-index (visually on top)
	return Utils.get_object_with_highest_z_index(result)

# Handle ending the player's turn
func _on_turn_manager_pressed() -> void:
	$"../Deck".currently_drawing_a_card = true
	
	# Discard current hand if any cards remain
	var player_hand_size = player_hand_reference.player_hand.size()
	if player_hand_size > 0:
		move_hand_to_discard()
		await Utils.create_timer(DEFAULT_CARD_MOVE_SPEED * player_hand_size)
	
	# Draw new hand and reset energy
	$"../Deck".draw_hand($"../Deck".CURRENT_HAND_DRAW)
	turn_manager.player_energy = 3
	turn_manager.update_player_energy_label()
