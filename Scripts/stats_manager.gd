extends Node

@export var _stats: Array[Stat]


func add_stat(stat: Stat) -> void:
	_stats.append(stat)


func get_stats() -> Array[Stat]:
	return _stats


func get_stat(stat_name: StringName) -> Stat:
	return _stats.get(_find_stat(stat_name))


func get_stat_value(stat_name: StringName) -> Variant:
	return _stats.get(_find_stat(stat_name)).value()


func upgrade_stat(stat_name: StringName) -> void:
	_stats.get(_find_stat(stat_name)).upgrade()


func _find_stat(stat_name: StringName) -> int:
	return _stats.find_custom(
		func(stat: Stat) -> int: return stat_name == stat.name()
	)
