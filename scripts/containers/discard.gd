extends Node2D

# Signals for pile view management
signal discard_pile_opened
signal discard_pile_closed
signal card_added_to_discard(card_id)

# Constants
const CARD_SCENE_PATH = "res://scenes/card.tscn"

# State
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

# Add a card to the discard pile
func add_to_discard(card_id: String) -> void:
	discard_pile.append(card_id)
	emit_signal("card_added_to_discard", card_id)
	update_discard_display()

# Updates the visual counter showing how many cards are in the discard pile
func update_discard_display() -> void:
	CardPileUtils.update_display(self, discard_pile.size())
	
	# Ensure counter is visible above everything (specific to discard)
	if has_node("RichTextLabel"):
		$RichTextLabel.z_index = 21

# Show the discard pile view UI
func view_discard_pile() -> void:
	CardPileUtils.view_pile(self, card_scene, discard_pile, false)
	
# Close the discard pile view
func close_discard_pile() -> void:
	CardPileUtils.close_pile(self, false)

# Gets all cards from the discard pile and empties it
# Used when recycling discard into the draw pile
func take_all_cards() -> Array:
	var cards = discard_pile.duplicate()
	discard_pile.clear()
	update_discard_display()
	return cards
