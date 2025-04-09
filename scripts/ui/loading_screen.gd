extends CanvasLayer

signal transition_completed
signal fade_in_completed
signal fade_out_completed

const FADE_DURATION = Utils.DEFAULT_ANIMATION_SPEED

func _ready():
	# Start fully transparent
	$ColorRect.modulate.a = 0

# Fade in, then emit signal when complete
func fade_in():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($ColorRect, "modulate:a", 1.0, FADE_DURATION)
	await tween.finished
	emit_signal("fade_in_completed")
	emit_signal("transition_completed")
	return true
	
# Fade out
func fade_out():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($ColorRect, "modulate:a", 0.0, FADE_DURATION)
	await tween.finished
	emit_signal("fade_out_completed")
	return true
