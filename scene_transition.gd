extends Control

signal transition_finished

const TRANSITION_DURATION = Utils.DEFAULT_ANIMATION_SPEED

# References to our viewports
@onready var viewport_1 = $Container/SubViewportContainer1/SubViewport
@onready var viewport_2 = $Container/SubViewportContainer2/SubViewport
@onready var container = $Container

var current_viewport_idx = 0  # Track which viewport contains current scene

func _ready():
	# Make this control fill the screen and be on top of everything
	z_index = 100
	
	# Hide this control by default
	visible = false

# Start a transition to a new scene
func transition_to_scene(scene_path: String):
	# Make the transition control visible
	visible = true
	
	# Store the current scene
	var current_scene = get_tree().current_scene
	
	# Remove current scene from its parent and add to our viewport
	var current_parent = current_scene.get_parent()
	if current_parent:
		current_parent.remove_child(current_scene)
	
	# Add current scene to the first viewport
	viewport_1.add_child(current_scene)
	
	# Load and instantiate the new scene
	var new_scene = load(scene_path).instantiate()
	
	# Add new scene to the second viewport
	viewport_2.add_child(new_scene)
	
	# Position the container to show the current scene
	container.position.y = 0
	
	# Create the sliding animation with multiple steps
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# 1. First nudge right (anticipation)
	var nudge_amount = get_viewport().size.y * 0.05  # 5% of screen width
	tween.tween_property(container, "position:y", nudge_amount, TRANSITION_DURATION * 2)
	
	# 2. Then slide left beyond target (overshoot)
	var target_pos = -get_viewport().size.y
	var overshoot = target_pos * 1.02  # 2% overshoot
	tween.tween_property(container, "position:y", overshoot, TRANSITION_DURATION)
	
	# 3. Finally settle at exact target (ease back)
	tween.tween_property(container, "position:y", target_pos, TRANSITION_DURATION * 1.5)
	
	# Wait for animation to complete
	await tween.finished
	
	# Remove scenes from viewports
	viewport_1.remove_child(current_scene)
	viewport_2.remove_child(new_scene)
	
	# Change the current scene
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	
	# Hide this control when done
	visible = false
	
	# Emit signal that transition is complete
	emit_signal("transition_finished")
