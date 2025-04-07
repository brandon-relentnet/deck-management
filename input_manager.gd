extends Node2D

# Signals for mouse button events
signal left_mouse_button_clicked
signal left_mouse_button_released

# Collision mask constants for detecting different game objects
const COLLISION_MASK_CARD = 1  # Used to identify cards
const COLLISION_MASK_DECK = 4  # Used to identify the deck

# References to other nodes
var card_manager_reference: Node2D
var deck_reference: Node2D

# Called when the node enters the scene tree
func _ready() -> void:
	# Get references to required nodes
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck"

# Process all input events
func _input(event: InputEvent) -> void:
	# Early return if this isn't a left mouse button event
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return
	
	if event.pressed:
		# Handle mouse button down
		emit_signal("left_mouse_button_clicked")
		raycast_at_cursor()
	else:
		# Handle mouse button up
		emit_signal("left_mouse_button_released")
			
# Detect and handle objects under the cursor when mouse is clicked
func raycast_at_cursor() -> void:
	# Set up the physics query
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	
	# Perform the raycast
	var result = space_state.intersect_point(parameters)
	
	# Early return if nothing was hit
	if result.size() == 0:
		return
	
	# Get the collision mask to determine what type of object was clicked
	var result_collision_mask = result[0].collider.collision_mask
	
	if result_collision_mask == COLLISION_MASK_CARD:
		# Handle card click
		var card_found = result[0].collider.get_parent()
		if card_found:
			card_manager_reference.start_drag(card_found)
	elif result_collision_mask == COLLISION_MASK_DECK:
		# Handle deck click
		deck_reference.draw_card()
