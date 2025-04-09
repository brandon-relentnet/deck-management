extends Node2D

signal draw_pile_opened
signal draw_pile_closed

# Constants for card creation and animation
const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_DRAW_SPEED = 0.3
const CURRENT_HAND_DRAW = 5

# Deck contents - stored as card IDs that reference the card database
var player_deck = [
	"power_1", "power_1", "power_1",
	"skill_1", "skill_1", "skill_1",
	"skill_2", "skill_2", "skill_2",
	"temp_1", "temp_1", "temp_1",
	"core_1", "core_1", "core_1",
	"power_1", "power_1", "power_1",
	"skill_1", "skill_1", "skill_1",
	"temp_1", "temp_1", "temp_1",
	"core_1", "core_1", "core_1",
]

# Load the card scene resource
var card_scene = preload(CARD_SCENE_PATH)
var currently_drawing_a_card: bool = false

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
	CardPileUtils.update_display(self, player_deck.size())

# Main function to draw a card from the deck
func draw_card() -> void:
	# Safety check: don't try to draw from an empty deck or if hand is full
	if $"../PlayerHand".player_hand.size() >= 8:
		return
	
	# Check if deck is empty and needs to refresh from discard
	if player_deck.size() == 0 and $"../Discard".discard_pile.size() > 0:
		await move_discard_to_draw()
	
	# If deck is still empty after trying to refresh, just return
	if player_deck.size() == 0:
		return
	
	# Create and add the card to the game
	spawn_card()

# Draw multiple cards to form a hand
func draw_hand(cards_to_draw) -> void:
	currently_drawing_a_card = true
	
	# First check if we need to refresh the deck before drawing
	if player_deck.size() == 0 and $"../Discard".discard_pile.size() > 0:
		await move_discard_to_draw()
	
	# Now draw the cards one by one
	for i in cards_to_draw:
		# Only try to draw if we have cards left
		if player_deck.size() > 0 or $"../Discard".discard_pile.size() > 0:
			await Utils.create_timer(CARD_DRAW_SPEED * 0.5)
			await draw_card()
	
	await Utils.create_timer(CARD_DRAW_SPEED * 0.5)
	currently_drawing_a_card = false

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
	new_card.name = "Card_" + card_id
	
	# Initial setup for better animation
	new_card.scale = Vector2(0.8, 0.8)
	new_card.rotation_degrees = -10
	new_card.modulate.a = 0.7
	
	# Add the card to the player's hand with animation
	$"../PlayerHand".add_card_to_hand_with_effects(new_card, CARD_DRAW_SPEED)
	
	# Add a subtle shake effect to the deck when drawing
	Utils.apply_shake_effect(self)
	
	# Update the deck counter
	update_deck_display()

# Show the draw pile view UI (now uses CardPileUtils)
func view_draw_pile() -> void:
	CardPileUtils.view_pile(self, card_scene, player_deck, true)
	
# Close the draw pile view (now uses CardPileUtils)
func close_draw_pile() -> void:
	CardPileUtils.close_pile(self, true)

# Move cards from discard pile back to draw pile
func move_discard_to_draw() -> void:
	# Animation constants
	const ANIMATION_DURATION = 0.3
	const CARD_OFFSET = 0.015
	const CARDS_PER_ROW = 5
	
	# Get positions for animation
	var discard_position = $"../Discard".global_position
	var deck_position = global_position
	
	# Store the number of cards to move
	var card_count = $"../Discard".discard_pile.size()
	if card_count == 0:
		return
	
	# Create simplified visual effect for card movement
	for i in range(min(10, card_count)):
		var card_visual = Sprite2D.new()
		add_child(card_visual)
		
		# Setup visual
		card_visual.texture = load("res://assets/card-back-default.png")
		card_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		card_visual.global_position = discard_position
		card_visual.z_index = -1
		
		# Calculate a slightly different path for each card
		var offset_x = (i % CARDS_PER_ROW) * 15 - 30
		var offset_y = (i / CARDS_PER_ROW) * 15 - 15
		
		# Animate the card
		var tween = create_tween()
		tween.tween_property(card_visual, "global_position", 
			deck_position + Vector2(offset_x, offset_y), 
			ANIMATION_DURATION).set_delay(i * CARD_OFFSET)
		tween.tween_property(card_visual, "modulate:a", 0, 0.15)
		
		# Setup automatic deletion after animation completes
		tween.tween_callback(card_visual.queue_free)
	
	# Move all cards from discard to deck array
	while $"../Discard".discard_pile.size() > 0:
		var card_id = $"../Discard".discard_pile.pop_back()
		player_deck.append(card_id)
	
	# Update displays
	$"../Discard".update_discard_display()
	update_deck_display()
	
	# Wait for the animation to complete
	await Utils.create_timer(ANIMATION_DURATION + (card_count * CARD_OFFSET) + 0.2)
	
	# Shuffle the deck
	player_deck.shuffle()
