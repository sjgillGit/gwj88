
## Static script for abstracting the tedious aspects
## of building objects
class_name Build
extends Node


static func root_scene(new_scene: PackedScene, current_scene: Node, root_node: Node) -> Node:
	var new_tscn: Node = new_scene.instantiate()
	if current_scene:
		current_scene.queue_free()
	root_node.add_child(new_tscn)
	return new_tscn
