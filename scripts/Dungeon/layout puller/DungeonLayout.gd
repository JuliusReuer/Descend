class_name DungeonLayout

var master_room_dict: Dictionary[String,DungeonLayoutNode] = {}
var start_node: String

var pending_connections: Dictionary[String,String] = {}  # to,from

var dead_end: Array[String]

var to_start_map: Dictionary[String,String] = {}
var to_finish_map: Dictionary[String,String] = {}


func add(dungeon_floor: DungeonGenerator, floor_id: int, room_id: int):
	var new_node = DungeonLayoutNode.new()
	new_node.uuid = "floor_%d_room_%d" % [floor_id, room_id]
	new_node.floor_id = floor_id

	var room = dungeon_floor.rooms[room_id]

	for connection in room._connected_rooms:
		new_node.add_connection(connection)

	new_node.room_rect = Rect2(room.get_position(), room.get_size())

	if room._room_type == DungeonRoom.DungeonRoomType.END:
		new_node.add_connection(0, floor_id + 1)
		if master_room_dict.has(DungeonLayoutNode.ID_STR % [floor_id + 1, 0]):
			master_room_dict[DungeonLayoutNode.ID_STR % [floor_id + 1, 0]].connections.append(
				new_node.uuid
			)
		else:
			pending_connections.set(DungeonLayoutNode.ID_STR % [floor_id + 1, 0], new_node.uuid)

	for pending in pending_connections:
		if pending == new_node.uuid:
			new_node.connections.append(pending_connections[pending])
			pending_connections.erase(pending)

	if len(new_node.connections) == 1:
		if room._room_type == DungeonRoom.DungeonRoomType.ROOM:
			dead_end.append(new_node.uuid)

	master_room_dict[new_node.uuid] = new_node
