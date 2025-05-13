class_name Ability
extends Resource
@export var id: String
@export var gates: int
## Chance of placing this Ability in an Important spot: 1/spread (0 <= always)
@export var spread: int

@export_enum("Early Game", "Midd Game", "End Game") var game_play_time_stamp: int
