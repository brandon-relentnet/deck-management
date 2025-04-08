extends Node2D

# Signals for mouse button events
signal left_mouse_button_clicked
signal left_mouse_button_released

# State tracking
var draw_pile_view_open = false

# References to other nodes
var card_manager_reference: Node2D
var deck_reference: Node2D
var discard_reference: Node2D

# Called when the node enters the scene tree
func _ready() -> void:
	# Get references to required nodes
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck"
	discard_reference = $"../Discard"
	
	# Connect to signals
	deck_reference.connect("draw_pile_opened", _on_draw_pile_opened)
	deck_reference.connect("draw_pile_closed", _on_draw_pile_closed)

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
		emit_signal("left_mouse_button_clicked")
		process_click()
	else:
		emit_signal("left_mouse_button_released")
			
# Handle mouse clicks on game objects
func process_click() -> void:
	# First check for cards - they have higher priority
	var result = Utils.raycast_check_for_object(get_world_2d(), get_global_mouse_position(), Utils.CARD_COLLISION_MASK)
	if result.size() > 0:
		var card_found = result[0].collider.get_parent()
		if card_found:
			card_manager_reference.start_drag(card_found)
			return
			
	# Then check for deck/discard
	result = Utils.raycast_check_for_object(get_world_2d(), get_global_mouse_position(), Utils.DECK_DISCARD_COLLISION_MASK)
	if result.size() > 0:
		var parent_node = result[0].collider.get_parent()
		
		if parent_node == deck_reference:
			deck_reference.view_draw_pile()
		elif parent_node == discard_reference:
			print("Viewing the discard pile")
			# Add discard pile functionality here if needed
