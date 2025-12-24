class_name UpgradeStats
extends Resource

@export var upgrade_name := ""
@export_multiline var description := ""
@export_multiline var hint := ""
@export var cost := 1000
# Upgrade stat static values
# use get_x() in the upgrade to get the current dynamic value
@export_range(-1.0, 1.0, 0.001) var control := 0.0
@export var thrust := 0.0
@export var lift := 0
@export_range(-1.0, 1.0, 0.000001) var drag := 0.0
# (-1.0, 1.0, 0.00001)
@export var mass := 1.0

@export var ramp_walk_speed := 0.0
@export var ramp_downforce := 0.0

## possible other stats?
# resist wind/snow? idk
@export var holiday_spirit := 0.0
# smash through walls?
@export var toughness := 0.0

@export var fuel_capacity_seconds := 0.0
