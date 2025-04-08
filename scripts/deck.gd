extends Node2D

# Constants for card creation and animation
const CARD_SCENE_PATH = "res://scenes/card.tscn"  # Path to the card scene file
const CARD_DRAW_SPEED = 0.3                   # Animation speed when drawing a card
const CURRENT_HAND_DRAW = 5

# Deck contents - stored as card IDs that reference the card database
var player_deck = [
	"knight_1", "knight_2", "knight_3",
	"knight_1", "knight_2", "knight_3",
	"knight_1", "knight_2", "knight_3",
	"knight_1", "knight_2", "knight_3",
	"knight_1", "knight_2", "knight_3",
	"knight_1", "knight_2", "knight_3",
	"mage_3", "mage_3", "mage_3",
	"mage_3", "mage_3", "mage_3",
]

# Load the card scene resource
var card_scene = preload(CARD_SCENE_PATH)
var currently_drawing_a_card: bool = false
# Reference array to keep cards from being freed prematurely
var active_card_visuals = []

# Called when the node enters the scene tree
func _ready() -> void:
	# Shuffle the deck at the start of the game
	player_deck.shuffle()
	
	# Draw initial hand
	draw_hand(CURRENT_HAND_DRAW)
	
	# Initialize the deck counter display
	update_deck_display()

# Updates the visual counter showing how many cards are left in the deck
func update_deck_display() -> void:
	$RichTextLabel.text = str(player_deck.size())

# Main function to draw a card from the deck
func draw_card() -> void:
	# Safety check: don't try to draw from an empty deck or if hand is full
	if $"../PlayerHand".player_hand.size() >= 8:
		return
	
	# Check if deck is empty and needs to refresh from discard
	if player_deck.size() == 0 and $"../Discard".discard_pile.size() > 0:
		# We need to properly wait for the complete animation
		await move_discard_to_draw()
	
	# If deck is still empty after trying to refresh, just return
	if player_deck.size() == 0:
		return
	
	# Create and add the card to the game
	spawn_card()

func draw_hand(cards_to_draw) -> void:
	currently_drawing_a_card = true
	
	# First check if we need to refresh the deck before drawing
	if player_deck.size() == 0 and $"../Discard".discard_pile.size() > 0:
		# Wait for the entire animation to complete before drawing any cards
		await move_discard_to_draw()
	
	# Now draw the cards one by one
	for i in cards_to_draw:
		# Only try to draw if we have cards left
		if player_deck.size() > 0 or $"../Discard".discard_pile.size() > 0:
			# Using a slightly progressive delay between cards for more natural feel
			await get_tree().create_timer(CARD_DRAW_SPEED * 0.5).timeout
			await draw_card()
	
	await get_tree().create_timer(CARD_DRAW_SPEED * 0.5).timeout
	currently_drawing_a_card = false

# Disables the deck visuals and interaction when empty
func disable_deck() -> void:
	pass
	#$Area2D/CollisionShape2D.disabled = true  # Disable collision to prevent further interaction
	#$Sprite2D.visible = false                 # Hide deck sprite
	#$RichTextLabel.visible = false            # Hide card counter

# Creates a new card instance and adds it to the player's hand
func spawn_card() -> void:
	# Take the first card ID from the deck
	var card_id = player_deck[0]
	player_deck.erase(card_id)
	
	# Create a new instance of the card
	var new_card = card_scene.instantiate()
	
	# Set up the card with data from the card database
	new_card.setup_from_id(card_id)
	
	# Add the card to the card manager for proper tracking
	$"../CardManager".add_child(new_card)
	new_card.name = "Card_" + card_id  # Use the card ID for the node name
	
	# Initial setup for better animation
	new_card.scale = Vector2(0.8, 0.8)  # Start smaller
	new_card.rotation_degrees = -10     # Start slightly rotated
	new_card.modulate.a = 0.7           # Start slightly transparent
	
	# Add the card to the player's hand with animation
	$"../PlayerHand".add_card_to_hand_with_effects(new_card, CARD_DRAW_SPEED)
	
	# Add a subtle shake effect to the deck when drawing
	apply_deck_shake()
	
	# Update the deck counter
	update_deck_display()
	
	# If that was the last card, disable the deck visuals and interaction
	if player_deck.size() == 0:
		disable_deck()

func apply_deck_shake() -> void:
	# Create a small shake animation for the deck
	var tween = create_tween()
	var original_pos = position
	
	# Quick back-and-forth movement
	tween.tween_property(self, "position", original_pos + Vector2(3, 0), 0.05)
	tween.tween_property(self, "position", original_pos, 0.05)

func move_discard_to_draw() -> void:
	# Clear any leftover card visuals from previous animations
	for old_visual in active_card_visuals:
		if is_instance_valid(old_visual):
			old_visual.queue_free()
	active_card_visuals.clear()
	
	# Animation constants
	const ANIMATION_DURATION = 0.3
	const CARD_OFFSET = 0.015  # Small time offset between cards
	const ARC_HEIGHT = -150    # Height of the parabolic arc
	
	# Get positions for animation
	var discard_position = $"../Discard".global_position
	var deck_position = global_position
	
	# Store the number of cards to animate
	var card_count = $"../Discard".discard_pile.size()
	if card_count == 0:
		return  # Return early if there's nothing to animate
	
	# Create and setup all card visuals at once - initially stacked perfectly
	var card_visuals = []
	
	# Get z_index values of discard and draw piles to ensure cards are under them
	var discard_z_index = $"../Discard".z_index
	var draw_z_index = z_index
	
	# Use a lower z_index to make cards appear underneath both piles
	var animation_z_index = min(discard_z_index, draw_z_index) - 1
	
	for i in card_count:
		var card_visual = Sprite2D.new()
		add_child(card_visual)
		
		# All cards start at exactly the same position (perfect stack)
		card_visual.texture = load("res://assets/red-card-back.png")
		card_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		card_visual.global_position = discard_position
		card_visual.self_modulate.a = 0.7
		
		# Make sure the z_index is lower than both piles
		card_visual.z_index = animation_z_index
		
		card_visuals.append(card_visual)
		# Add to reference array to prevent premature freeing
		active_card_visuals.append(card_visual)
	
	# First animate cards slightly apart to create the "fanning" effect
	for i in card_count:
		var fan_offset = Vector2(i * 1.5, i * 0.5)  # Subtle offset for fanning
		var tween = create_tween()
		tween.tween_property(card_visuals[i], "global_position", 
							discard_position + fan_offset, 0.2)
	
	# Wait for the fanning animation to complete
	await get_tree().create_timer(0.2).timeout
	
	# Move all cards from discard to deck array
	while $"../Discard".discard_pile.size() > 0:
		var card_node = $"../Discard".discard_pile.pop_back()
		# Extract the card_id from the discarded card node
		if is_instance_valid(card_node) and card_node.has_method("get") and card_node.get("card_id"):
			player_deck.append(card_node.card_id)
			# Now that we've stored the card ID, we can safely remove the node
			card_node.queue_free()
	
	# Update displays
	$"../Discard".update_discard_display()
	update_deck_display()
	
	# Animate cards along smooth arc path
	for i in card_count:
		# Skip if card was somehow removed
		if i >= card_visuals.size() or !is_instance_valid(card_visuals[i]):
			continue
			
		var start_pos = card_visuals[i].global_position
		var end_pos = deck_position
		var control_point = Vector2(
			(start_pos.x + end_pos.x) / 2,
			min(start_pos.y, end_pos.y) - ARC_HEIGHT
		)
		
		# Create tween for smooth bezier curve motion
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_IN_OUT)
		
		# Add rotation animation for more dynamism
		tween.parallel().tween_property(card_visuals[i], "rotation_degrees", 
										randi_range(-20, 20), ANIMATION_DURATION)
		
		# Create a customized callable for bezier animation that uses a local reference
		# This avoids the "previously freed" error by using the stored local reference
		var target_card = card_visuals[i]
		var callable = func(t: float):
			if is_instance_valid(target_card):
				# Quadratic Bezier formula: (1-t)²P₀ + 2(1-t)tP₁ + t²P₂
				var one_minus_t = 1.0 - t
				target_card.global_position = one_minus_t * one_minus_t * start_pos + \
										2 * one_minus_t * t * control_point + \
										t * t * end_pos
		
		# Use custom method to move along a quadratic bezier curve
		tween.tween_method(
			callable,
			0.0,  # Start progress
			1.0,  # End progress
			ANIMATION_DURATION
		).set_delay(i * CARD_OFFSET)
		
		# Fade out at the end
		tween.tween_property(card_visuals[i], "modulate:a", 0, 0.15)
	
	# Wait for the last card animation to complete
	await get_tree().create_timer(ANIMATION_DURATION + (card_count * CARD_OFFSET) + 0.5).timeout
	
	# Remove all the temporary visuals
	for card_visual in active_card_visuals:
		if is_instance_valid(card_visual):
			card_visual.queue_free()
	active_card_visuals.clear()
	
	# Shuffle the deck
	player_deck.shuffle()
