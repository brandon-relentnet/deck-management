extends Node
# This script centralizes all card effect functions
# It should be attached to an autoload singleton node named "CardEffects"

# Process all effects for a given card
func process_card_effects(card, game_state):
	if not card:
		return
		
	# Get card effects and amount
	var effects = card.effects
	var effect_amount = card.effect_amount
	
	print("Processing effects for: ", card.card_name)
	print(" - Effects: ", effects)
	print(" - Amount: ", effect_amount)
	
	# Process each effect
	for effect in effects:
		call_effect(effect, effect_amount, game_state)

# Call the appropriate effect function based on effect name
func call_effect(effect_name, amount, game_state):
	match effect_name:
		"draw_card":
			draw_cards(amount, game_state)
		"deal_damage":
			deal_damage(amount, game_state)
		"gain_energy":
			gain_energy(amount, game_state)
		"gain_block":
			gain_block(amount, game_state)
		"heal":
			heal(amount, game_state)
		_:
			push_error("Unknown effect: " + effect_name)

# Effect: Draw cards
func draw_cards(amount, game_state):
	print("Drawing ", amount, " card(s)")
	# Convert amount to int if it's stored as string
	var cards_to_draw = int(amount) if amount is String else amount
	
	# Get reference to deck node
	var deck = game_state.get("deck")
	if deck and deck.has_method("draw_hand"):
		deck.draw_hand(cards_to_draw)
	else:
		push_error("Cannot draw cards - invalid deck reference")

# Effect: Deal damage
func deal_damage(amount, game_state):
	print("Dealing ", amount, " damage")
	# Convert amount to int if it's stored as string
	var damage = int(amount) if amount is String else amount
	
	# Get reference to enemy manager
	var enemy_manager = game_state.get("enemy_manager")
	if enemy_manager and enemy_manager.has_method("take_damage"):
		enemy_manager.take_damage(damage)
	else:
		push_error("Cannot deal damage - invalid enemy manager reference")

# Effect: Gain energy
func gain_energy(amount, game_state):
	print("Gaining ", amount, " energy")
	# Convert amount to int if it's stored as string
	var energy = int(amount) if amount is String else amount
	
	# Get reference to turn manager
	var turn_manager = game_state.get("turn_manager")
	if turn_manager:
		turn_manager.player_energy += energy
		turn_manager.update_player_energy_label()
	else:
		push_error("Cannot gain energy - invalid turn manager reference")

# Effect: Gain block (defense)
func gain_block(amount, game_state):
	print("Gaining ", amount, " block")
	# Convert amount to int if it's stored as string
	var block = int(amount) if amount is String else amount
	
	# Get reference to player stats
	var player_stats = game_state.get("player_stats")
	if player_stats and player_stats.has_method("add_block"):
		player_stats.add_block(block)
	else:
		push_error("Cannot gain block - invalid player stats reference")

# Effect: Heal
func heal(amount, game_state):
	print("Healing ", amount, " HP")
	# Convert amount to int if it's stored as string
	var heal_amount = int(amount) if amount is String else amount
	
	# Get reference to player stats
	var player_stats = game_state.get("player_stats")
	if player_stats and player_stats.has_method("heal"):
		player_stats.heal(heal_amount)
	else:
		push_error("Cannot heal - invalid player stats reference")
