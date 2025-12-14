extends Camera3D


@export var min_distance := 2.0
@export var max_distance := 40.0
@export var angle_v_adjust := 0.0

@export var height := 1.5
@export_node_path var attach_point
var _collision_exception: Array[RID] = []
var _attach_point: Node3D

func _ready():
	_attach_point = get_node_or_null(attach_point) if attach_point else null
	# Find collision exceptions for ray.
	var node = self
	while(node):
		if (node is RigidBody3D):
			_collision_exception.append(node.get_rid())
			break
		else:
			node = node.get_parent()

	# This detaches the camera transform from the parent spatial node.
	top_level = true


func _physics_process(_delta):
	var body := get_parent() as RigidBody3D
	if body.angular_velocity.length() < 10.0 && _attach_point != null:
		assert(_attach_point.get_parent() == get_parent(), "attach_point should be a sibling otherwise we need better math")
		transform = _attach_point.transform
		top_level = false
	else:
		top_level = true
		var target = get_parent().get_global_transform().origin
		var pos = get_global_transform().origin

		var state := get_world_3d().direct_space_state
		var q := PhysicsRayQueryParameters3D.create(pos, target, 0xFF, _collision_exception)
		var col := state.intersect_ray(q)
		if col:
			pos = col.position - col.normal * 10
		var from_target = pos - target

		# Check ranges.
		if !col:
			if from_target.length() < min_distance:
				from_target = from_target.normalized() * min_distance
			elif from_target.length() > max_distance:
				from_target = from_target.normalized() * max_distance

		from_target.y = height

		pos = target + from_target

		look_at_from_position(pos, target, Vector3.UP)

		# Turn a little up or down
		var t = transform
		t.basis = Basis(t.basis[0], deg_to_rad(angle_v_adjust)) * t.basis
		transform = t
