extends Node3D

func set_run_speed(value: float):
	var at := %AnimationTree
	at.set("parameters/running/blend_amount", absf(value))
	at.set("parameters/run_timescale/scale", value * 3)
