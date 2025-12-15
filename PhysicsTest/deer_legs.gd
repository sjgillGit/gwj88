extends Node3D

@export_node_path("RigidBody3D") var main_body: NodePath

func _ready():
	var mb := get_node_or_null(main_body) if main_body else null
	if mb:
		for c in find_children("*", "ConeTwistJoint3D"):
			c.node_a = mb.get_path()
