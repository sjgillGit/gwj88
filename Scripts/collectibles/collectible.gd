@tool
extends Area3D
class_name Collectible

const BIG_PICKUP_SOUND := preload("res://Assets/audio/sfx/VB GWJ 88 - big pickup.wav")
const SMALL_PICKUP_SOUND := preload("res://Assets/audio/sfx/VB GWJ 88 - small pickup.wav")


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
	if item.color == Color.BLACK:
		item.color = Color.from_ok_hsl(randf(), randf_range(0.5, 1.0), randf_range(0.5, 1.0))

func _in_flight_area() -> bool:
	return owner && owner is FlightMain


func _update_asset():
	var item_instance := get_node_or_null("Item")
	if item_instance && item.asset:
		item_instance.free()
	if item.asset:
		var ps := item.asset.instantiate() as Node3D
		ps.name = "Item"
		$CollectibleContainer.add_child(ps, true)
		if 'color' in ps:
			ps.color = item.color
		if _in_flight_area():
			ps.transform.basis = ps.transform.basis.scaled(Vector3.ONE * item.game_scale)
		var aabb := AABB(Vector3.ONE, Vector3.ONE * 2)
		for mi: MeshInstance3D in ps.find_children("*", "MeshInstance3D"):
			aabb = aabb.merge(mi.mesh.get_aabb())
		$CollisionShape3D.shape.radius = aabb.get_longest_axis_size() * 3.0
