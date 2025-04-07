extends Node2D

# Collision mask constants for physics interactions
const COLLISION_MASK_CARD = 1      # Used for detecting cards
const COLLISION_MASK_CARD_SLOT = 2 # Used for detecting card slots
const DEFAULT_CARD_MOVE_SPEED = 0.1 # Default animation speed for card movement
const DISCARD_PILE_POSITION = Vector2(1770, 890)

# State variables
var card_being_dragged: Node2D = null  # Reference to the card currently being dragged
var screen_size: Vector2               # Cached screen dimensions to limit card movement
var is_hovering_on_card: bool = false  # Tracks if the cursor is hovering over any card
var player_hand_reference: Node2D      # Reference to the player's hand node

# Called when the node enters the scene tree
func _ready() -> void:
	# Cache screen size for boundary checking
	screen_size = get_viewport_rect().size
	
	# Get reference to the player hand node
	player_hand_reference = $"../PlayerHand"
	
	# Connect to input manager's mouse release signal
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)

# Called every frame
func _process(_delta: float) -> void:
	# Early return if no card is being dragged - optimization to avoid unnecessary processing
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
	# Reset scale to normal when dragging
	card.scale = Vector2(1, 1)

# Finish dragging a card and determine where it should go
func finish_drag() -> void:
	# Slightly enlarge the card for visual feedback
	card_being_dragged.scale = Vector2(1.05, 1.05)
	
	# Check if the card is over a valid card slot
	var card_slot = raycast_check_for_card_slot()
	
	#print(card_slot)
	
	if card_slot and not card_slot.card_in_slot:
		# Place card in slot
		player_hand_reference.remove_card_from_hand(card_being_dragged)
		card_being_dragged.position = card_slot.position
		card_slot.played_card = card_being_dragged
		# Disable collision to prevent further interaction with placed card
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		card_slot.card_in_slot = true
		# Move card from slot to discard pile and allow for more cards to be played
		move_card_to_discard(card_slot.played_card)
		card_slot.card_in_slot = false
	else:
		# Return card to hand if not placed in a slot
		player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	
	# Clear dragging reference
	card_being_dragged = null

func move_card_to_discard(card) -> void:
	$"../PlayerHand".animate_card_to_position(card, DISCARD_PILE_POSITION, DEFAULT_CARD_MOVE_SPEED)
	$"../Discard".discard_pile.append(card)
	$"../Discard".update_discard_display()
	await get_tree().create_timer(DEFAULT_CARD_MOVE_SPEED).timeout
	remove_child(card)
	print($"../Discard".discard_pile)
	
func move_hand_to_discard() -> void:
	player_hand_reference.player_hand.reverse()
	for i in player_hand_reference.player_hand:
		move_card_to_discard(i)
		await get_tree().create_timer(DEFAULT_CARD_MOVE_SPEED).timeout
	player_hand_reference.clear_hand()
		
# Connect signals from newly created cards to this manager
func connect_card_signals(card: Node2D) -> void:
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

# Handler for mouse button release
func on_left_click_released() -> void:
	if card_being_dragged:
		finish_drag()

# Handler for when the mouse enters a card's area
func on_hovered_over_card(card: Node2D) -> void:
	# Only update if we weren't already hovering over a card
	if not is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
	
# Handler for when the mouse exits a card's area
func on_hovered_off_card(card: Node2D) -> void:
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
	# Ternary operators for concise visual state changes
	card.scale = Vector2(1.05, 1.05) if hovered else Vector2(1, 1)
	card.z_index = 2 if hovered else 1

# Convenience wrapper for checking for card slots at the current mouse position
func raycast_check_for_card_slot() -> Node2D:
	return raycast_check_for_object(COLLISION_MASK_CARD_SLOT)

# Convenience wrapper for checking for cards at the current mouse position
func raycast_check_for_card() -> Node2D:
	var result = raycast_check_for_object(COLLISION_MASK_CARD)
	if not result or result.size() == 0:
		return null
	
	# If multiple cards are under the cursor, get the one with highest z-index (visually on top)
	return get_card_with_highest_z_index(result)

# Generic function for detecting objects at the mouse position with a specific collision mask
func raycast_check_for_object(collision_mask: int):
	# Set up the physics query
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = collision_mask
	
	# Perform the raycast
	var result = space_state.intersect_point(parameters)
	
	if result.size() > 0:
		# For card slots, return the parent node directly
		if collision_mask == COLLISION_MASK_CARD_SLOT:
			return result[0].collider.get_parent()
		# For cards, return the whole result array for z-index sorting
		return result
	return null
	
# From an array of physics results, find the card with the highest z-index
func get_card_with_highest_z_index(cards: Array) -> Node2D:
	# Start with the first card as our candidate
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	# Check all other cards
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	
	return highest_z_card

func _on_turn_manager_pressed() -> void:
	$"../Deck".currently_drawing_a_card = true
	# Move hand to discard pile
	move_hand_to_discard()
	await get_tree().create_timer(DEFAULT_CARD_MOVE_SPEED * 10).timeout
	$"../Deck".draw_hand(5)
