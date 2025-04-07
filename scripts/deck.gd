extends Node2D

# Constants for card creation and animation
const CARD_SCENE_PATH = "res://scenes/card.tscn"  # Path to the card scene file
const CARD_DRAW_SPEED = 0.25                      # Animation speed when drawing a card

# Deck contents - the cards available to draw
var player_deck = ["Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight", "Knight"]
# Load the card scene resource
var card_scene = preload(CARD_SCENE_PATH)

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
	# Safety check: don't try to draw from an empty deck
	if player_deck.size() == 0 or $"../PlayerHand".player_hand.size() >= 10:
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
	for i in cards_to_draw:
		await get_tree().create_timer(0.2).timeout
		draw_card()

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
