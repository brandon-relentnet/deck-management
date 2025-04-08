extends Node2D

# Signals
signal hovered(card)
signal hovered_off(card)

# Core properties
var card_id: String = ""
var energy: int = 0
var card_name: String = ""

# Card state
var hand_position: Vector2
var is_being_dragged: bool = false

# Called when the node enters the scene tree
func _ready() -> void:
	# Register card signals with the card manager
	if get_parent().has_method("connect_card_signals"):
		get_parent().connect_card_signals(self)
	
	# Set up initial visual properties
	# modulate.a = 0.9
	scale = Vector2(1, 1)
	z_index = 1

# Set up the card with data from the card database
func setup_from_id(id: String) -> void:
	# Get card data from registry
	var card_data = CardDB.get_card_data(id)
	if card_data.is_empty():
		push_error("Failed to set up card - invalid ID: " + id)
		return
	
	# Store the card ID for reference
	card_id = id
	
	# Set the card's properties
	card_name = card_data.name
	energy = card_data.energy
	
	# Update visual elements
	if has_node("NameLabel"):
		$NameLabel.text = card_name
	
	if has_node("EnergyLabel"):
		$EnergyLabel.text = str(energy)

# Mouse entered card area
func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

# Mouse exited card area
func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)

# Input event in card area
func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Start dragging only if player has enough energy
			var turn_manager = get_node("/root/Main/TurnManager")
			
			if turn_manager.player_energy >= energy:
				get_node("/root/Main/CardManager").start_drag(self)
				is_being_dragged = true
