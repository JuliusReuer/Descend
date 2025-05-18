class_name DungeonLayout

var master_room_dict: Dictionary[String,DungeonLayoutNode] = {}
var start_node: String

var pending_connections: Dictionary[String,String] = {}  # to,from

var dead_end: Array[String]

var to_start_map: Dictionary[String,String] = {}
var to_finish_map: Dictionary[String,String] = {}

var floor_entrys: Dictionary[int,String] = {}


func add(dungeon_floor: DungeonGenerator, floor_id: int, room_id: int):
	var new_node = DungeonLayoutNode.new()
	new_node.uuid = "floor_%d_room_%d" % [floor_id, room_id]

	var room = dungeon_floor.rooms[room_id]

	for connection in room._connected_rooms:
		new_node.add_connection(connection)

	new_node.room_rect = Rect2(room.get_position(), room.get_size())

	if room._room_type == DungeonRoom.DungeonRoomType.END:
		if floor_entrys.has(floor_id + 1):
			master_room_dict[floor_entrys[floor_id + 1]].connections.append(new_node.uuid)
			new_node.connections.append(floor_entrys[floor_id + 1])
		else:
			pending_connections.set("floor_" + str(floor_id + 1), new_node.uuid)

	if room._room_type == DungeonRoom.DungeonRoomType.START:
		floor_entrys.set(floor_id, new_node.uuid)
		for pending in pending_connections:
			if new_node.uuid.begins_with(pending):
				new_node.connections.append(pending_connections[pending])
				master_room_dict[pending_connections[pending]].connections.append(new_node.uuid)
				pending_connections.erase(pending)
				break

	if len(new_node.connections) == 1:
		if room._room_type == DungeonRoom.DungeonRoomType.ROOM:
			dead_end.append(new_node.uuid)

	master_room_dict[new_node.uuid] = new_node
