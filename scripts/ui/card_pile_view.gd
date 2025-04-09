extends Node
class_name CardPileUtils
# Enums for pile type
enum PileType {DRAW, DISCARD}
# Update the displayed count of cards in the pile
static func update_display(pile_node: Node2D, count: int) -> void:
	# Apply shake effect when cards are added/removed
	Utils.apply_shake_effect(pile_node)
	# Update the text in the relevant labels
	if pile_node.has_node("RichTextLabel"):
		pile_node.get_node("RichTextLabel").text = str(count)

	var pile_name = "Draw" if pile_node.name == "Deck" else "Discard"
	var pile_label = pile_node.get_node("../CardPileView/" + pile_name + "PileLabel")
	pile_label.text = str(count)
	
# Show the card pile view
static func view_pile(pile_node: Node2D, card_scene: PackedScene, card_ids: Array, is_draw_pile: bool) -> void:
	var pile_type = PileType.DRAW if is_draw_pile else PileType.DISCARD
	var pile_name = "Draw" if is_draw_pile else "Discard"

	# Emit the appropriate signal
	if is_draw_pile:
		pile_node.emit_signal("draw_pile_opened")
	else:
		pile_node.emit_signal("discard_pile_opened")

	# Get references to UI components
	var pile_view_container = pile_node.get_node("../CardPileView")
	var grid_container = pile_node.get_node("../CardPileView/" + pile_name + "PileScroll/MarginContainer/GridContainer")

	# Clear any existing cards in the view
	for child in grid_container.get_children():
		child.queue_free()

	# For draw pile, we want to shuffle the display to hide the actual order
	var display_card_ids = card_ids.duplicate()
	if is_draw_pile:
		display_card_ids.shuffle()

	# Create a visual representation for each card in the pile
	for card_id in display_card_ids:
		var new_card = card_scene.instantiate()
		
		new_card.setup_from_id(card_id)
		
		# Reset rotation to avoid UI issues
		new_card.rotation_degrees = 0

		# Cards need a minimum size to render properly in container
		var control = Control.new()
		control.custom_minimum_size = Vector2(160, 240)
		control.add_child(new_card)

		# Position the card within its Control container
		new_card.position = Vector2(60, 90)

		grid_container.add_child(control)

		# Disable dragging or other interactions for these preview cards
		if new_card.has_node("Area2D"):
			new_card.get_node("Area2D").input_pickable = false

	# Make sure the view is visible
	pile_view_container.visible = true
	pile_node.get_node("../CardPileView/" + pile_name + "PileScroll").visible = true
	
# Close the card pile view
static func close_pile(pile_node: Node2D, is_draw_pile: bool) -> void:
	var pile_name = "Draw" if is_draw_pile else "Discard"

	# Hide the view
	pile_node.get_node("../CardPileView").visible = false
	pile_node.get_node("../CardPileView/" + pile_name + "PileScroll").visible = false

	# Emit the appropriate signal
	if is_draw_pile:
		pile_node.emit_signal("draw_pile_closed")
	else:
		pile_node.emit_signal("discard_pile_closed")
