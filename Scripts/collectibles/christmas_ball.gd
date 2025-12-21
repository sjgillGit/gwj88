extends Node3D

var color: Color:
	set(v):
		color = v
		assert(is_node_ready())
		var mat := $MeshInstance3D.mesh.material.duplicate() as StandardMaterial3D
		mat.albedo_color = color
		$MeshInstance3D.set_surface_override_material(0, mat)
