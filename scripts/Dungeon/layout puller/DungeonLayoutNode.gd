class_name DungeonLayoutNode

var uuid: String
var floor_id: int
var connections: Array[String] = []
var room_rect: Rect2


func add_connection(connection: int, dungeon_floor: int = -1):
	if dungeon_floor == -1:
		dungeon_floor = floor_id
	connections.append("floor_%d_room_%d" % [dungeon_floor, connection])


func _to_string() -> String:
	return "Dungeonroom<" + uuid + ">"
