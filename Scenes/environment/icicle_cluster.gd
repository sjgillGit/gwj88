extends RigidBody3D


func _on_body_entered(body: Node) -> void:
	if body is DeerMissile:
		await get_tree().process_frame
		var tfm := global_transform
		var p := get_parent()
		p.remove_child(self)
		var parts = preload("./icicle_cluster_parts.tscn").instantiate()
		p.add_child(parts)
		parts.global_transform = tfm
		free()
