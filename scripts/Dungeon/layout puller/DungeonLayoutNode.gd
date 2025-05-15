class_name DungeonLayoutNode

const ID_STR = "floor_%d_room_%d"

var uuid: String
var floor_id: int
var connections: Array[String] = []
var room_rect: Rect2


func add_connection(connection: int, dungeon_floor: int = -1):
	if dungeon_floor == -1:
		dungeon_floor = floor_id
	connections.append(ID_STR % [dungeon_floor, connection])


func _to_string() -> String:
	return "Dungeonroom<" + uuid + ">"


static func get_data(id: String) -> Vector2i:
	var reg = RegEx.create_from_string("floor_(\\d*)_room_(\\d*)")
	var m = reg.search(id)
	if m:
		return Vector2i(int(m.get_string(1)), int(m.get_string(2)))
	return Vector2i.ZERO


static func get_floor(id: String) -> int:
	return get_data(id).x


static func get_room(id: String) -> int:
	return get_data(id).y


static func is_floor(id: String, floor: int) -> bool:
	return id.begins_with("floor_%d" % floor)
