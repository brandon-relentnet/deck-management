extends Node2D

# Constants for card creation and animation
const CARD_SCENE_PATH = "res://scenes/card.tscn"  # Path to the card scene file
const CARD_DRAW_SPEED = 0.25                      # Animation speed when drawing a card

# Deck contents - the cards available to draw
var player_deck = ["Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight"]
# Load the card scene resource
var card_scene = preload(CARD_SCENE_PATH)
var currently_drawing_a_card: bool = false

# Called when the node enters the scene tree
func _ready() -> void:
	draw_hand(5)
	# Initialize the deck counter display
	update_deck_display()

# Updates the visual counter showing how many cards are left in the deck
func update_deck_display() -> void:
	$RichTextLabel.text = str(player_deck.size())

# Main function to draw a card from the deck
func draw_card() -> void:
	# Safety check: don't try to draw from an empty deck or if hand is full
	if $"../PlayerHand".player_hand.size() >= 10:
		return
	
	# Check if deck is empty and needs to refresh from discard
	if player_deck.size() == 0 and $"../Discard".discard_pile.size() > 0:
		# We need to properly wait for the complete animation
		await move_discard_to_draw()
	
	# If deck is still empty after trying to refresh, just return
	if player_deck.size() == 0:
		return
	
	# Take the first card from the deck
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	# If that was the last card, disable the deck visuals and interaction
	if player_deck.size() == 0:
		disable_deck()
	
	# Update the deck counter
	update_deck_display()
	
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
			await get_tree().create_timer(CARD_DRAW_SPEED).timeout
			await draw_card()
	
	await get_tree().create_timer(CARD_DRAW_SPEED).timeout
	currently_drawing_a_card = false

# Disables the deck visuals and interaction when empty
func disable_deck() -> void:
	pass
	#$Area2D/CollisionShape2D.disabled = true  # Disable collision to prevent further interaction
	#$Sprite2D.visible = false                 # Hide deck sprite
	#$RichTextLabel.visible = false            # Hide card counter

# Creates a new card instance and adds it to the player's hand
func spawn_card() -> void:
	# Create a new instance of the card
	var new_card = card_scene.instantiate()
	
	# Add the card to the card manager for proper tracking
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	
	# Add the card to the player's hand with animation
	$"../PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)

func move_discard_to_draw() -> void:
	# Animation constants
	const ANIMATION_DURATION = 0.7
	const CARD_OFFSET = 0.03  # Small time offset between cards
	const ARC_HEIGHT = 250    # Height of the parabolic arc
	
	# Get positions for animation
	var discard_position = $"../Discard".global_position
	var deck_position = global_position
	
	# Store the number of cards to animate
	var card_count = $"../Discard".discard_pile.size()
	if card_count == 0:
		return  # Return early if there's nothing to animate
	
	# This function is now properly awaitable
	
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
		card_visual.texture = load("res://assets/gold-card.png")
		card_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		card_visual.global_position = discard_position
		card_visual.self_modulate.a = 0.7
		
		# Make sure the z_index is lower than both piles
		card_visual.z_index = animation_z_index
		
		card_visuals.append(card_visual)
	
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
		player_deck.append($"../Discard".discard_pile.pop_back())
	
	# Update displays
	$"../Discard".update_discard_display()
	update_deck_display()
	
	# Animate cards along smooth arc path
	for i in card_count:
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
		
		# Use custom method to move along a quadratic bezier curve
		tween.tween_method(
			func(t: float):
				# Quadratic Bezier formula: (1-t)²P₀ + 2(1-t)tP₁ + t²P₂
				var one_minus_t = 1.0 - t
				card_visuals[i].global_position = one_minus_t * one_minus_t * start_pos + \
										2 * one_minus_t * t * control_point + \
										t * t * end_pos,
			0.0,  # Start progress
			1.0,  # End progress
			ANIMATION_DURATION
		).set_delay(i * CARD_OFFSET)
		
		# Fade out at the end
		tween.tween_property(card_visuals[i], "modulate:a", 0, 0.15)
	
	# Wait for the last card animation to complete
	await get_tree().create_timer(ANIMATION_DURATION + (card_count * CARD_OFFSET) + 0.2).timeout
	
	# Remove all the temporary visuals
	for card_visual in card_visuals:
		card_visual.queue_free()
	
	# Shuffle the deck
	player_deck.shuffle()
