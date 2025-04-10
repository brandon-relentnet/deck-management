# Add this script to your Main node in main.tscn
extends Node2D

const ANIMATION_SPEED: float = Utils.DEFAULT_ANIMATION_SPEED
const HAND_DRAW = Utils.CURRENT_HAND_DRAW

var deck
var discard
var drag_handler
var turn_manager

func _ready():
	GameManager.start_game.connect(setup_game)
	# Get references to deck and discard
	deck = $Deck
	discard = $Discard
	drag_handler = $CardDragHandler
	turn_manager = $TurnManager
	
	# Hide the objects initially
	deck.modulate.a = 0
	discard.modulate.a = 0
	turn_manager.modulate.a = 0
		
func setup_game():
	# Initialize game state based on GameManager settings
	# For example, you might load a specific deck based on settings
	print("Starting game at level: ", GameManager.current_level)
	
	await Utils.create_timer(ANIMATION_SPEED)
	
	# Optional: Dramatic entrance animation
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	# Animate positions and fade in simultaneously
	tween.parallel().tween_property(deck, "position", deck.position, ANIMATION_SPEED).from(Vector2(deck.position.x, deck.position.y + 300))
	tween.parallel().tween_property(deck, "modulate:a", 1.0, ANIMATION_SPEED)
	
	tween.parallel().tween_property(discard, "position", discard.position, ANIMATION_SPEED).from(Vector2(discard.position.x, discard.position.y + 300))
	tween.parallel().tween_property(discard, "modulate:a", 1.0, ANIMATION_SPEED)
	
	tween.parallel().tween_property(turn_manager, "position", turn_manager.position, ANIMATION_SPEED).from(Vector2(turn_manager.position.x, turn_manager.position.y + 300))
	tween.parallel().tween_property(turn_manager, "modulate:a", 1.0, ANIMATION_SPEED)
	
	drag_handler.get_screen_size()
	
	await Utils.create_timer(ANIMATION_SPEED)
	deck.draw_hand(HAND_DRAW)
