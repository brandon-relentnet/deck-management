extends Node

signal transition_finished

var transition_scene = preload("res://scenes/scene_transition.tscn")
var transition_instance = null

func _ready():
	# Create the transition instance
	transition_instance = transition_scene.instantiate()
	
	# Connect to its signal
	transition_instance.transition_finished.connect(func(): emit_signal("transition_finished"))
	
	# We don't add it to the scene tree until needed

func change_scene(scene_path: String):
	# Add the transition to the scene tree
	get_tree().root.add_child(transition_instance)
	
	# Start the transition
	transition_instance.transition_to_scene(scene_path)
	
	# Return the signal so callers can await it
	return transition_finished
