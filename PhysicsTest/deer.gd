extends RigidBody3D

@export var thrust_magnitude := 500.0
var thrust: Vector3

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var local_thrust := global_basis * thrust
	state.apply_central_impulse(local_thrust * thrust_magnitude * state.step)
	%PhysicsStats.text = "Speed: %.2f m/s" % state.linear_velocity.length()

func _on_move_button_button_down() -> void:
	thrust = Vector3(0,0,1)
	sleeping = false

func _on_move_button_button_up() -> void:
	thrust = Vector3()
