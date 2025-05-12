class_name DungeonLayout

var master_room_dict: Dictionary[String,DungeonLayoutNode] = {}


func add(dungeon_floor: DungeonGenerator, floor_id: int, room_id: int):
	var new_node = DungeonLayoutNode.new()
	new_node.uuid = "floor_%d_room_%d" % [floor_id, room_id]
	new_node.floor_id = floor_id

	var room = dungeon_floor.rooms[room_id]

	for connection in room._connected_rooms:
		new_node.add_connection(connection)

	new_node.room_rect = Rect2(room.get_position(), room.get_size())

	master_room_dict[new_node.uuid] = new_node
