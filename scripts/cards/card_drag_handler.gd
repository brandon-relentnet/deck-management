extends Node2D

# Constants
const DEFAULT_CARD_MOVE_SPEED = Utils.DEFAULT_ANIMATION_SPEED
const DRAG_SMOOTHING = 20.0  # Higher = less lag, lower = more lag

# Signal for starting and stopping card drag
signal drag_started(card)
signal drag_ended(card, target_slot)

# State variables
var card_being_dragged: Node2D = null
var screen_size: Vector2
var is_hovering_on_card: bool = false

# References to other systems
var player_hand: Node2D
var play_handler: Node2D
var input_manager: Node2D

func _ready() -> void:
	# Cache common references - using get_node_or_null for safety
	screen_size = get_viewport_rect().size
	player_hand = get_node_or_null("../PlayerHand")
	play_handler = get_node_or_null("../CardPlayHandler")
	input_manager = get_node_or_null("../InputManager")
	
	# Validate required dependencies
	if not player_hand:
		push_error("PlayerHand not found!")
	
	if not play_handler:
		push_error("CardPlayHandler not found!")
	
	if not input_manager:
		push_error("InputManager not found!")
	else:
		# Connect to input manager's mouse release signal with error checking
		if input_manager.has_signal("left_mouse_button_released"):
			# Disconnect first in case the connection already exists
			if input_manager.is_connected("left_mouse_button_released", Callable(self, "on_left_click_released")):
				input_manager.disconnect("left_mouse_button_released", Callable(self, "on_left_click_released"))
			
			# Now connect
			input_manager.connect("left_mouse_button_released", on_left_click_released)
		else:
			push_error("InputManager missing expected signal 'left_mouse_button_released'")

# Called every frame
func _process(delta: float) -> void:
	if not card_being_dragged:
		return
	
	# Get the target position (mouse position with screen boundaries)
	var mouse_pos = get_global_mouse_position()
	var target_position = Vector2(
		clamp(mouse_pos.x, 0, screen_size.x), 
		clamp(mouse_pos.y, 0, screen_size.y)
	)
	
	# Smoothly move the card toward the target position
	card_being_dragged.position = card_being_dragged.position.lerp(
		target_position, 
		min(1.0, DRAG_SMOOTHING * delta)
	)

# Begin dragging a card
func start_drag(card: Node2D) -> void:
	# Don't allow drag operations when draw pile view is open
	if input_manager and (input_manager.draw_pile_view_open or input_manager.discard_pile_view_open):
		return
		
	card_being_dragged = card
	card.is_being_dragged = true
	set_card_scale(card, false)
	
	emit_signal("drag_started", card)

# Finish dragging a card and determine where it should go
func finish_drag() -> void:
	if !is_instance_valid(card_being_dragged):
		card_being_dragged = null
		return
		
	set_card_scale(card_being_dragged, true)
	
	# Check if the card is over a valid card slot
	var card_slot = raycast_check_for_card_slot()
	
	emit_signal("drag_ended", card_being_dragged, card_slot)
	
	# Try to play the card if conditions are met
	if play_handler and play_handler.has_method("try_play_card"):
		if play_handler.try_play_card(card_being_dragged, card_slot):
			# Card was played successfully
			pass
		else:
			# Return card to hand
			_return_card_to_hand()
	else:
		# Play handler not available, just return card to hand
		_return_card_to_hand()
	
	# Reset the card's dragging state before clearing reference
	card_being_dragged.is_being_dragged = false
	card_being_dragged = null

# Helper function to return a card to hand
func _return_card_to_hand() -> void:
	# Important: First check if card is already in the hand before returning it
	if player_hand and card_being_dragged:
		if card_being_dragged in player_hand.player_hand:
			# If already in hand, just animate it back to its stored position
			Utils.animate_node_with_effects(card_being_dragged, card_being_dragged.hand_position, DEFAULT_CARD_MOVE_SPEED)
		else:
			# Only add to hand if it's not already there
			player_hand.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)

# Handler for mouse button release
func on_left_click_released() -> void:
	if card_being_dragged:
		finish_drag()

# Handler for when the mouse enters a card's area
func on_hovered_over_card(card: Node2D) -> void:
	# Skip hover effects if draw pile view is open
	if input_manager and (input_manager.draw_pile_view_open or input_manager.discard_pile_view_open):
		return
		
	# Only update if we weren't already hovering over a card
	if not is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
	
# Handler for when the mouse exits a card's area
func on_hovered_off_card(card: Node2D) -> void:
	# Skip hover effects if draw pile view is open
	if input_manager and (input_manager.draw_pile_view_open or input_manager.discard_pile_view_open):
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
