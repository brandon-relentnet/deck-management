extends Node

# This script acts as a database/registry for all card types
# It should be attached to an autoload singleton node named "CardDB"

# Dictionary of all card types in the game
# Each entry contains the full definition of a card type
var card_registry = {
	"knight_1": {
		"id": "knight_1",
		"name": "Knight",
		"energy": 1,
		"icon": "res://assets/knight_icon.png",
		"effects": []
	},
	"knight_2": {
		"id": "knight_2",
		"name": "Knight+",
		"energy": 2,
		"icon": "res://assets/knight_icon.png", 
		"effects": []
	},
	"knight_3": {
		"id": "knight_3",
		"name": "Knight++",
		"energy": 3,
		"icon": "res://assets/knight_icon.png",
		"effects": []
	},
	"mage_3": {
	"id": "mage_3",
	"name": "Mage",
	"energy": 3,
	"icon": "res://assets/mage_icon.png",
	"effects": ["deal_damage", "draw_card"]
	},
	# Add more card definitions here as you expand your game
}

# Function to get a card's data by ID
func get_card_data(card_id: String) -> Dictionary:
	if card_registry.has(card_id):
		return card_registry[card_id]
	else:
		push_error("Card ID not found in registry: " + card_id)
		return {}
		
# Function to get a list of all card IDs
func get_all_card_ids() -> Array:
	return card_registry.keys()

# Function to create a card ID from name and energy
# Useful when constructing a deck
func create_card_id(card_name: String, card_energy: int) -> String:
	var id = name.to_lower() + "_" + str(card_energy)
	if card_registry.has(id):
		return id
	else:
		push_error("Cannot create card ID - no card found with name " + card_name + " and energy " + str(card_energy))
		return ""
