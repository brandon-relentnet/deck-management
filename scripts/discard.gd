extends Node2D

var discard_pile: Array = []

func _ready() -> void:
	update_discard_display()

func update_discard_display() -> void:
	$RichTextLabel.text = str(discard_pile.size())
