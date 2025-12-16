extends Node3D

func _ready():
	Engine.time_scale = 0.25

func _on_button_pressed() -> void:
	$DeerMissile.linear_velocity = Vector3(0 ,0, 10)
	$DeerMissile.angular_velocity = Vector3()
	$DeerMissile.transform = Transform3D()
