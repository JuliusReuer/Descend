class_name Placeable
extends Resource
@export var name:String
@export_multiline var discription:String

@export_category("Placable Data")
@export var id: String
@export_group("Generation Stats")
## Chance of placing this Ability in an Important spot: 1/spread (0 <= always)
@export var spread: int
@export_enum("Early Game", "Midd Game", "End Game", "Any") var game_play_time_stamp: int
@export var item_amount: int = 1
