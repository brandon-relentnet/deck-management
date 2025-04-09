extends Node

signal start_game

# Game state variables
var player_name: String = "Player"
var difficulty: String = "Normal"
var current_level: int = 1

# Statistics and progression
var games_played: int = 0
var games_won: int = 0

# Called when the singleton is loaded
func _ready():
	print("Game Manager initialized")

# Start a new game
func start_new_game():
	games_played += 1
	current_level = 1
	# Additional game setup logic here

# End current game
func end_game(victory: bool = false):
	if victory:
		games_won += 1
	
	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# Save game data (simple implementation)
func save_game():
	var save_data = {
		"player_name": player_name,
		"games_played": games_played,
		"games_won": games_won
	}
	
	var save_file = FileAccess.open("user://save_data.json", FileAccess.WRITE)
	save_file.store_line(JSON.stringify(save_data))

# Load game data (simple implementation)
func load_game():
	if FileAccess.file_exists("user://save_data.json"):
		var save_file = FileAccess.open("user://save_data.json", FileAccess.READ)
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.data
			player_name = data["player_name"]
			games_played = data["games_played"]
			games_won = data["games_won"]
