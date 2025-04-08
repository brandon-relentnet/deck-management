extends Node2D

# Signals for mouse button events
signal left_mouse_button_clicked
signal left_mouse_button_released

# Collision mask constants for detecting different game objects
const COLLISION_MASK_CARD = 1  # Used to identify cards
const COLLISION_MASK_DECK = 4  # Used to identify the deck
const COLLISION_MASK_DISCARD = 4  # Currently sharing the same mask as deck

# References to other nodes
var card_manager_reference: Node2D
var deck_reference: Node2D
var discard_reference: Node2D
var draw_pile_view_open = false

# Called when the node enters the scene tree
func _ready() -> void:
	# Get references to required nodes
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck"
	discard_reference = $"../Discard"
	
	# Connect to signals
	deck_reference.connect("draw_pile_opened", Callable(self, "_on_draw_pile_opened"))
	deck_reference.connect("draw_pile_closed", Callable(self, "_on_draw_pile_closed"))

func _on_draw_pile_opened() -> void:
	draw_pile_view_open = true

func _on_draw_pile_closed() -> void:
	draw_pile_view_open = false

# Process all input events
func _input(event: InputEvent) -> void:
	if draw_pile_view_open:
		return
		
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
			
func set_draw_pile_view_state(is_open: bool) -> void:
	draw_pile_view_open = is_open
	
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
	
	# Get the collision object and its parent node
	var collider = result[0].collider
	var parent_node = collider.get_parent()
	
	# Check what type of object was clicked by comparing with actual node references
	if collider.collision_mask == COLLISION_MASK_CARD:
		# Handle card click
		var card_found = parent_node
		if card_found:
			card_manager_reference.start_drag(card_found)
	elif collider.collision_mask == COLLISION_MASK_DECK:
		# Now we need to determine if this is the deck or discard pile
		if parent_node == deck_reference:
			# This is the actual deck - handle deck click
			# deck_reference.draw_card()
			deck_reference.view_draw_pile()
		elif parent_node == discard_reference:
			# This is the discard pile
			print("Viewing the discard pile")
			# Add discard pile functionality here if needed
