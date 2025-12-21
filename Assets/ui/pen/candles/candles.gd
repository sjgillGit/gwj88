extends Node3D

func _ready():
	$AnimationPlayer.seek(randf())
