class_name Stairs
extends Node2D

var cur_room_id: String
var other_room_id: String

@onready var sprite: Sprite2D = $Sprite2D


func set_floor(current_room: String, id: String) -> void:
	cur_room_id = current_room
	other_room_id = id
	if other_room_id == "outside":
		sprite.frame = 0
		return
	var dir: int = DungeonLayoutNode.get_floor(current_room) - DungeonLayoutNode.get_floor(id)
	if dir == 1:
		sprite.frame = 0
