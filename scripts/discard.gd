extends Node2D

signal discard_pile_opened
signal discard_pile_closed

const CARD_SCENE_PATH = "res://scenes/card.tscn"

var discard_pile: Array = []
var card_scene = preload(CARD_SCENE_PATH)

# Called when the node enters the scene tree
func _ready():
	# Set high z-index for this node and its visual elements
	z_index = 20
	
	if has_node("Sprite2D"):
		$Sprite2D.z_index = 20
	
	# Initialize the discard counter display
	update_discard_display()

# Updates the visual counter showing how many cards are in the discard pile
func update_discard_display() -> void:
	# Apply shake effect when cards are added/removed
	Utils.apply_shake_effect(self)
	
	if has_node("RichTextLabel"):
		$RichTextLabel.text = str(discard_pile.size())
		$"../CardPileView/DiscardPileLabel".text = str(discard_pile.size())
		# Ensure counter is visible above everything
		$RichTextLabel.z_index = 21

# Show the draw pile view UI
func view_discard_pile() -> void:
	emit_signal("discard_pile_opened")
	
	# Clear any existing cards in the view
	for child in $"../CardPileView/DiscardPileScroll/MarginContainer/GridContainer".get_children():
		child.queue_free()
	
	# Create a visual representation for each card in the draw pile
	for card_id in discard_pile:
		var new_card = card_scene.instantiate()
		new_card.setup_from_id(card_id)
		
		# Reset rotation to avoid UI issues
		new_card.rotation_degrees = 0
		
		# Cards need a minimum size to render properly in HBoxContainer
		var control = Control.new()
		control.custom_minimum_size = Vector2(160, 240)
		control.add_child(new_card)
		
		# Position the card within its Control container
		new_card.position = Vector2(60, 90)
		
		$"../CardPileView/DiscardPileScroll/MarginContainer/GridContainer".add_child(control)
		
		# Disable dragging or other interactions for these preview cards
		if new_card.has_node("Area2D"):
			new_card.get_node("Area2D").input_pickable = false
	
	# Make sure the TextureRect is visible
	$"../CardPileView".visible = true
	$"../CardPileView/DiscardPileScroll".visible = true
	
# Close the draw pile view
func close_discard_pile() -> void:
	$"../CardPileView".visible = false
	$"../CardPileView/DiscardPileScroll".visible = false
	emit_signal("discard_pile_closed")
