extends Button

func _process(_delta) -> void:
	if $"../Deck".currently_drawing_a_card == true:
		disabled = true
	else:
		disabled = false
