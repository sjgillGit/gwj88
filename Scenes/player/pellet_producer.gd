class_name PelletProducer
extends RayCast3D

@export var max_pellet_time := 600.0

const _pellet = preload("res://Scenes/player/pellet.tscn")
const _max_pellets = 200

var _in_scene_pellets: Array
@onready var _pellet_timer: Timer = $PelletTimer


func _ready() -> void:
	_pellet_timer.wait_time = _get_next_pellet_time()
	_pellet_timer.start()


func _get_next_pellet_time():
	var wait_time = randf_range(10.0, max_pellet_time)
	print("New pellet time %s" % wait_time)
	return wait_time


func _add_pellets(count: int):
	print("Adding %s pellets" % count)
	for i in range(count):
		var p = _pellet.instantiate()
		_in_scene_pellets.push_front(p)
		add_child(p)


func _remove_pellets(count: int):
	if count <= 0:
		return
	print("Removing %s pellets" % count)
	var remove_count = min(count, len(_in_scene_pellets))
	for i in range(remove_count):
		var p = _in_scene_pellets.pop_back()
		p.queue_free()


func emit_pellets() -> void:
	var add_count = randi_range(20, 50)
	var overflow_count = (len(_in_scene_pellets) + add_count) - _max_pellets
	_remove_pellets(overflow_count)
	_add_pellets(add_count)
	_pellet_timer.stop()
	_pellet_timer.wait_time = _get_next_pellet_time()
	_pellet_timer.start()
