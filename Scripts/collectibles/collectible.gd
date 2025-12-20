@tool
extends Node3D
class_name Collectible

@export var item: Item:
	set(value):
		item = value
		if is_node_ready():
			if item && !item.changed.get_connections().any(func(c): return c.callable == _update_asset):
				item.changed.connect(_update_asset)
			_update_asset()


func _ready() -> void:
	# force setter to rerun
	item = item


func _update_asset():
	var item_instance := get_node_or_null("Item")
	if item_instance && item.asset:
		item_instance.free()
	if item.asset:
		var ps := item.asset.instantiate()
		ps.name = "Item"
		add_child(ps, true)
		var aabb := AABB(Vector3.ONE, Vector3.ONE * 2)
		for mi: MeshInstance3D in ps.find_children("*", "MeshInstance3D"):
			aabb = aabb.merge(mi.mesh.get_aabb())
		$CollisionShape3D.shape.radius = aabb.get_longest_axis_size()
