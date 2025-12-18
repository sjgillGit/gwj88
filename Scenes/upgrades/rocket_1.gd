extends MeshInstance3D

func _ready():
	get_parent().thrusting_changed.connect(set_thrusting)


func set_thrusting(value: bool):
	%ThrustParticles.emitting = value
