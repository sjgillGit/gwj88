class_name UpgradeStats
extends Resource

@export var upgrade_name := ""
@export_multiline var description := ""
@export var cost := 1000
# Upgrade stat static values
# use get_x() to get the current dynamic value
@export var thrust := 0.0
@export var lift := 0
@export var drag := 0
@export var mass := 1.0

## possible other stats?
# resist wind/snow? idk
@export var holiday_spirit := 0.0
# smash through walls?
@export var toughness := 0.0

@export var fuel_capacity_seconds := 0.0
