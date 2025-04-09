extends Node2D

# Signals for mouse button events
signal left_mouse_button_clicked
signal left_mouse_button_released
signal pile_view_toggled(pile_type, is_open)

# Enum for pile types
enum PileType { DRAW, DISCARD }

# State tracking
var draw_pile_view_open = false
var discard_pile_view_open = false

# References to other nodes
var deck_reference: Node2D
var discard_reference: Node2D

# Called when the node enters the scene tree
func _ready() -> void:
	# Get references to required nodes
	deck_reference = $"../Deck"
	discard_reference = $"../Discard"
	
	# Connect to signals
	deck_reference.connect("draw_pile_opened", _on_draw_pile_opened)
	deck_reference.connect("draw_pile_closed", _on_draw_pile_closed)
	discard_reference.connect("discard_pile_opened", _on_discard_pile_opened)
	discard_reference.connect("discard_pile_closed", _on_discard_pile_closed)
	
# Event handlers for pile view state changes
func _on_draw_pile_opened() -> void:
	draw_pile_view_open = true
	emit_signal("pile_view_toggled", PileType.DRAW, true)

func _on_draw_pile_closed() -> void:
	draw_pile_view_open = false
	emit_signal("pile_view_toggled", PileType.DRAW, false)
	
func _on_discard_pile_opened() -> void:
	discard_pile_view_open = true
	emit_signal("pile_view_toggled", PileType.DISCARD, true)

func _on_discard_pile_closed() -> void:
	discard_pile_view_open = false
	emit_signal("pile_view_toggled", PileType.DISCARD, false)

# Process all input events
func _input(event: InputEvent) -> void:
	# Early return if this isn't a left mouse button event
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return
	
	if event.pressed:
		emit_signal("left_mouse_button_clicked")
		print("left mouse pressed")
		process_click()
	else:
		emit_signal("left_mouse_button_released")
			
# Handle mouse clicks on game objects
func process_click() -> void:
	# First check for deck/discard since those can toggle a view
	var result = Utils.raycast_check_for_object(get_world_2d(), get_global_mouse_position(), Utils.DECK_DISCARD_COLLISION_MASK)
	if result.size() > 0:
		var parent_node = result[0].collider.get_parent()
		
		if parent_node in [deck_reference, discard_reference]:
			# Check if we're clicking on the deck or discard
			var is_deck = parent_node == deck_reference
			
			# Get references to the relevant pile objects based on what was clicked
			var clicked_pile = deck_reference if is_deck else discard_reference
			var other_pile = discard_reference if is_deck else deck_reference
			
			# Check if the clicked pile's view is already open
			var clicked_pile_open = draw_pile_view_open if is_deck else discard_pile_view_open
			var other_pile_open = discard_pile_view_open if is_deck else draw_pile_view_open
			
			if clicked_pile_open:
				# If clicked pile is already open, close it
				if is_deck:
					clicked_pile.close_draw_pile()
				else:
					clicked_pile.close_discard_pile()
			else:
				# If the other pile is open, close it first
				if other_pile_open:
					if is_deck:
						other_pile.close_discard_pile()
					else:
						other_pile.close_draw_pile()
				
				# Open the clicked pile
				if is_deck:
					clicked_pile.view_draw_pile()
				else:
					clicked_pile.view_discard_pile()
					
			# Found and processed a pile click, so we're done
			return
			
	# If we get here, the click wasn't on a pile
	# Check if we need to close any open pile views
	if draw_pile_view_open:
		deck_reference.close_draw_pile()
	elif discard_pile_view_open:
		discard_reference.close_discard_pile()
