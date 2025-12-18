extends RigidBody3D

func _ready():
	var o := owner
	while o:
		if o is RigidBody3D:
			o.add_collision_exception_with(self)
		o = o.owner
