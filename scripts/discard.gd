extends Node2D

var discard_pile: Array = []

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
		# Ensure counter is visible above everything
		$RichTextLabel.z_index = 21
