extends RigidBody3D

@export var replace_with: PackedScene
@export var destroy_after := 2

var _hit_count := 0

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is DeerMissile:
		_hit_count += 1
		if _hit_count >= destroy_after:
			_destroy.call_deferred()

func _destroy():
	await get_tree().process_frame
	if is_inside_tree() && !is_queued_for_deletion():
		var tfm := global_transform
		var p := get_parent()
		if replace_with:
			p.remove_child(self)
			var parts = replace_with.instantiate()
			p.add_child(parts)
			parts.global_transform = tfm
			if !is_queued_for_deletion():
				queue_free()
		else:
			collision_mask = 2
			collision_layer = 2
