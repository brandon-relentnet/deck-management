extends Node

# This script contains utility functions that can be reused across different parts of the game
# It should be attached to an autoload singleton node named "Utils"

# Constants that might be needed in multiple places
const DEFAULT_ANIMATION_SPEED = 0.1
const CARD_COLLISION_MASK = 1
const CARD_SLOT_COLLISION_MASK = 2
const DECK_DISCARD_COLLISION_MASK = 4

# Creates and returns a timer with the specified duration
# This is more convenient than calling get_tree().create_timer() everywhere
static func create_timer(duration: float):
	return Engine.get_main_loop().create_timer(duration).timeout

# Generic function for detecting objects at the mouse position with a specific collision mask
static func raycast_check_for_object(world_2d: World2D, global_mouse_position: Vector2, collision_mask: int):
	# Set up the physics query
	var space_state = world_2d.direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = global_mouse_position
	parameters.collide_with_areas = true
	parameters.collision_mask = collision_mask
	
	# Perform the raycast
	return space_state.intersect_point(parameters)

# Animate a node to a new position with visual effects
static func animate_node_with_effects(node: Node2D, new_position: Vector2, speed: float) -> void:
	var tween = node.create_tween()
	
	# Set better easing for more natural movement
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Move the node to its position
	tween.tween_property(node, "position", new_position, speed)
	
	# Animate the node's rotation to 0 (if applicable)
	tween.parallel().tween_property(node, "rotation_degrees", 0, speed)
	
	# Scale animation - growing to normal size
	tween.parallel().tween_property(node, "scale", Vector2(1, 1), speed)
	
	# Fade in animation
	tween.parallel().tween_property(node, "modulate:a", 1.0, speed * 0.8)

# Apply a shake effect to a node
static func apply_shake_effect(node: Node2D, offset: Vector2 = Vector2(3, 3), duration: float = 0.05) -> void:
	var tween = node.create_tween()
	var original_pos = node.position
	
	# Quick back-and-forth movement
	tween.tween_property(node, "position", original_pos + offset, duration)
	tween.tween_property(node, "position", original_pos, duration)

# From an array of physics results, find the object with the highest z-index
static func get_object_with_highest_z_index(results: Array) -> Node2D:
	if results.size() == 0:
		return null
		
	# Start with the first object as our candidate
	var highest_z_object = results[0].collider.get_parent()
	var highest_z_index = highest_z_object.z_index
	
	# Check all other objects
	for i in range(1, results.size()):
		var current_object = results[i].collider.get_parent()
		if current_object.z_index > highest_z_index:
			highest_z_object = current_object
			highest_z_index = current_object.z_index
	
	return highest_z_object
