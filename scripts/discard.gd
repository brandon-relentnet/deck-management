extends Node2D

var discard_pile: Array = []

# Called when the node enters the scene tree for the first time
func _ready():
	# Ensure the discard pile sprite has a much higher z-index
	# If you have a sprite for the discard pile, make sure it has a higher z-index
	if has_node("Sprite2D"):
		$Sprite2D.z_index = 20  # Set this to a higher value
	elif has_node("TextureRect"):
		$TextureRect.z_index = 20  # Alternative if using TextureRect
	
	# Make sure this node's z-index is also high to affect child nodes
	z_index = 20
	
	# Initialize the discard counter display
	update_discard_display()

# Updates the visual counter showing how many cards are in the discard pile
func update_discard_display() -> void:
	if has_node("RichTextLabel"):
		$RichTextLabel.text = str(discard_pile.size())
		# Ensure counter is visible above everything
		$RichTextLabel.z_index = 21

# This function should be called once (e.g., from _ready) to
# recursively set high z-index for all child nodes
func ensure_high_z_index() -> void:
	# Set high z-index for all direct children (except for cards in discard_pile)
	for child in get_children():
		if child is Sprite2D or child is TextureRect or child is RichTextLabel:
			child.z_index = 20
