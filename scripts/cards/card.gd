extends Node2D
# Signals
signal hovered(card)
signal hovered_off(card)

# Core properties
var card_id: String = ""
var energy: int = 0
var card_name: String = ""
var card_manager: Node2D = null
var turn_manager: Node = null

# Effect properties
var effects: Array = []
var effect_amount: int = 0

# Card state
var hand_position: Vector2
var is_being_dragged: bool = false

# Default card front texture path
var default_card_front = "res://assets/card-front-default.png"

func init(cm: Node2D, tm: Node) -> void:
	card_manager = cm
	turn_manager = tm
	
	# Connect signals immediately if we have the card manager
	if card_manager and card_manager.has_method("connect_card_signals"):
		card_manager.connect_card_signals(self)

# Called when the node enters the scene tree
func _ready() -> void:
	pass
	# Set up initial visual properties
	#scale = Vector2(1, 1)
	#z_index = 1

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
	
	if card_data.has("effects"):
		effects = card_data.effects
		
	if card_data.has("effect_amount"):
		effect_amount = int(card_data.effect_amount)

	# Update visual elements
	if has_node("NameLabel"):
		$NameLabel.text = card_name
	
	if has_node("EnergyLabel"):
		$EnergyLabel.text = str(energy)
	
	# Update card front sprite based on card type
	if has_node("CardImage"):
		if card_data.has("card_type"):
			# Use custom card front if specified
			$CardImage.texture = load(card_data.card_type)
		else:
			# Otherwise use default card front
			$CardImage.texture = load(default_card_front)

	# Update card icon if it exists
	if has_node("CardIcon") and card_data.has("icon"):
		$CardIcon.texture = load(card_data.icon)
		$CardIcon.visible = true

	if has_node("EffectLabel") and card_data.has("effect_amount"):
		$EffectLabel.text = str(card_data.effect_amount)
		$EffectLabel.visible = true

# Mouse entered card area
func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

# Mouse exited card area
func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)

# Input event in card area
func _on_area_2d_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Use the injected turn_manager reference instead of trying to find it
		if not turn_manager:
			return
			
		#if turn_manager.player_energy < energy:
			#return
		
		# Use the injected card_manager reference
		if card_manager and card_manager.has_method("start_drag"):
			card_manager.start_drag(self)
			is_being_dragged = true

# Returns the card's effects array
func get_effects() -> Array:
	return effects

# Returns the card's effect amount
func get_effect_amount() -> int:
	return effect_amount
