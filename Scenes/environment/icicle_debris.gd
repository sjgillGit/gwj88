extends Node3D

var mesh_scale := 1.0:
	set(v):
		mesh_scale = v
		if is_node_ready():
			for d in get_children():
				d.mesh_scale = v
