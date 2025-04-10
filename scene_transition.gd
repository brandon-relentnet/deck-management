extends Control

signal transition_finished

const TRANSITION_DURATION = Utils.DEFAULT_ANIMATION_SPEED

# References to our viewports
@onready var viewport_1 = $Container/SubViewportContainer1/SubViewport
@onready var viewport_2 = $Container/SubViewportContainer2/SubViewport
@onready var container = $Container
@onready var screen_size = get_viewport_rect().size

func _ready():
	# Make this control fill the screen and be on top of everything
	z_index = 100
	
	# Hide this control by default
	visible = false
	
	# Make sure container is positioned correctly at start
	container.position = Vector2.ZERO

# Start a transition to a new scene
func transition_to_scene(scene_path: String):
	# Make the transition control visible
	visible = true
	
	# Store the current scene
	var current_scene = get_tree().current_scene
	
	# Remove current scene from its parent
	var current_parent = current_scene.get_parent()
	if current_parent:
		current_parent.remove_child(current_scene)
	
	# Load and instantiate the new scene
	var new_scene = load(scene_path).instantiate()
	
	# Setup transition based on target scene
	if new_scene.name == "MainMenu":
		# Going to MainMenu - it slides up from bottom
		# Place current scene in bottom viewport
		viewport_2.add_child(current_scene)
		
		# Place new scene in top viewport
		viewport_1.add_child(new_scene)
		
		# Start with container shifted up (showing new scene in top viewport)
		container.position.y = -screen_size.y
		
		# Perform slide-down animation
		var tween = create_tween()
		# 1. Slight inch down to simulate a pull effect (opposite of your inch up)
		tween.tween_property(container, "position:y", -screen_size.y * 1.05, TRANSITION_DURATION * 2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		# 2. Slide down but overshoot (go past zero)
		tween.tween_property(container, "position:y", screen_size.y * 0.05, TRANSITION_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		# 3. Bounce back to settle at the final position
		tween.tween_property(container, "position:y", 0, TRANSITION_DURATION * 1.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		
		# Wait for animation to complete
		await tween.finished
		
	else:
		# Going to another scene - it slides down from top
		# Place current scene (MainMenu) in top viewport
		viewport_1.add_child(current_scene)
		
		# Place new scene in bottom viewport
		viewport_2.add_child(new_scene)
		
		# Start with container at normal position (showing current scene)
		container.position = Vector2.ZERO
		
		# Perform slide-up animation
		var tween = create_tween()
		# Slight inch up to simulate a pull effect
		tween.tween_property(container, "position:y", screen_size.y * 0.05, TRANSITION_DURATION * 2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		# Slide down but overshoot
		tween.tween_property(container, "position:y", -screen_size.y * 1.05, TRANSITION_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
		# Fall back into place
		tween.tween_property(container, "position:y", -screen_size.y, TRANSITION_DURATION * 1.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		
		# Wait for animation to complete
		await tween.finished
		
	# Remove scenes from viewports after animation completes
	if viewport_1.get_child_count() > 0:
		viewport_1.remove_child(viewport_1.get_child(0))
	if viewport_2.get_child_count() > 0:
		viewport_2.remove_child(viewport_2.get_child(0))
	
	# Change the current scene
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	
	# Hide this control when done
	visible = false
	
	# Emit signal that transition is complete
	emit_signal("transition_finished")
