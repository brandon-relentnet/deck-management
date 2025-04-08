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
	CardPileUtils.update_display(self, discard_pile.size())
	
	# Ensure counter is visible above everything (specific to discard)
	if has_node("RichTextLabel"):
		$RichTextLabel.z_index = 21

# Show the discard pile view UI (now uses CardPileUtils)
func view_discard_pile() -> void:
	CardPileUtils.view_pile(self, card_scene, discard_pile, false)
	
# Close the discard pile view (now uses CardPileUtils)
func close_discard_pile() -> void:
	CardPileUtils.close_pile(self, false)
