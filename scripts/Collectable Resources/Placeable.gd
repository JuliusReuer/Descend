class_name Placeable
extends Resource

enum GamePlayTimeStamp {
	NONE = 0, EARLY = 1, MIDD = 2, EARLY_MIDD = 3, END = 4, EARLY_END = 5, MIDD_END = 6, ANY = 7
}

@export var name: String
@export_multiline var discription: String

@export_category("Placable Data")
@export var id: String
@export_group("Generation Stats")
## Chance of placing this Ability in an Important spot: 1/spread (0 <= always)
@export var spread: int
@export var game_play_time_stamp: GamePlayTimeStamp = GamePlayTimeStamp.EARLY
@export var amount: int = 1
