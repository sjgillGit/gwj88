extends Camera3D


@export var min_distance := 2.0
@export var max_distance := 40.0
@export var angle_v_adjust := 0.0
@export var max_attached_velocity := 5.0
@export var max_fov := 100
@export var slerp_amount := 0.5
@export var bubble_radius := 1.25

@export var height := 1.5
@export_node_path var attach_point: NodePath

var _collision_exception: Array[RID] = []
var _attach_point: Node3D
var _bubble_shape := SphereShape3D.new()
var _bubble_q_params := PhysicsShapeQueryParameters3D.new()

@onready var _base_fov := fov

func _ready():
	_bubble_shape.radius = bubble_radius * 2.0
	_bubble_q_params.collide_with_areas = false
	_bubble_q_params.collide_with_bodies = true
	_bubble_q_params.shape = _bubble_shape
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

func _safe_global_pos(body: RigidBody3D, state: PhysicsDirectSpaceState3D):
	_bubble_q_params.collision_mask = body.collision_mask
	_bubble_q_params.transform = global_transform
	_bubble_q_params.exclude = [body]
	var dist := 10.0
	_bubble_q_params.transform.origin += Vector3.UP * dist
	_bubble_q_params.motion = Vector3.DOWN * dist
	var amounts := state.cast_motion(_bubble_q_params)
	var safe_amount := amounts[0]
	if safe_amount == 1.0:
		return global_position
	return _bubble_q_params.transform.origin + _bubble_q_params.motion * safe_amount


func _physics_process(_delta):
	var body := get_parent() as RigidBody3D

	var state := get_world_3d().direct_space_state

	if body.angular_velocity.length() < max_attached_velocity && _attach_point != null:
		assert(_attach_point.get_parent() == get_parent(), "attach_point should be a sibling otherwise we need better math")
		var a_tfm = _attach_point.transform
		transform = Transform3D(transform.basis.slerp(a_tfm.basis, slerp_amount), transform.origin.lerp(a_tfm.origin, slerp_amount))
		global_position = _safe_global_pos(body, state)
		top_level = false
		fov = clampf(_base_fov + body.linear_velocity.length(), _base_fov, max_fov)
	else:
		fov = _base_fov
		top_level = true
		var target = get_parent().get_global_transform().origin
		var pos = get_global_transform().origin

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
		global_position = _safe_global_pos(body, state)
