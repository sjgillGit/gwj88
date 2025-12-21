class_name PenCollectible
extends RigidBody3D

const SCALE_AMOUNT := 0.65

var item: Item:
	set(v):
		item = v
		assert(is_node_ready())
		_update_item()


func _update_item():
	var ps := item.asset.instantiate()
	add_child(ps)
	if 'color' in ps:
		ps.color = item.color
	var aabb := AABB(Vector3(), Vector3())
	for mi: MeshInstance3D in ps.find_children("*", "MeshInstance3D"):
		aabb = aabb.merge(mi.mesh.get_aabb())
	ps.transform.basis = Basis().scaled(Vector3.ONE * SCALE_AMOUNT)
	var r := aabb.get_longest_axis_size() * 0.5 * SCALE_AMOUNT
	$CollisionShape3D.shape.radius = r if r > 0 else 0.5
