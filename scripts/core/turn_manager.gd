extends Button

var player_energy: int = 3

func _process(_delta) -> void:
	if $"../Deck".currently_drawing_a_card == true:
		disabled = true
	else:
		disabled = false

func update_player_energy_label() -> void:
	$RichTextLabel.text = str(player_energy)
