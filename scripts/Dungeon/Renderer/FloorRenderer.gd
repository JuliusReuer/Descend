class_name FloorRenderer
extends DungeonPipeline

@export var floor: int = 0
@export var map: TileMapLayer
#@export var layout_scale: float = 1
@export var camera: Camera2D
@export_category("Props")
@export var door: PackedScene
@export var chest: PackedScene
@export var stairs: PackedScene
var door_size = 4

var layout: DungeonLayout
var data: DungeonData
var renderer: TerrainRenderer = TerrainRenderer.new()

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var connection_list: Dictionary[String,bool] = {}
var stairs_list: Array[Stairs] = []


func to_dict(arr: Array[Vector2i]) -> Dictionary[Vector2i,bool]:
	var dict: Dictionary[Vector2i,bool] = {}
	for val in arr:
		dict.set(val, true)
	return dict


func start(dungeon: Dungeon):
	layout = dungeon.layout
	data = dungeon.data
	rng.seed = dungeon.rng.randi()
	teleport(0)


func clear():
	map.clear()
	renderer.clear()
	for child in map.get_children():
		map.remove_child(child)

	#define render sequence
	renderer.define(Vector2i(0, 3))  #Invisible Wall
	renderer.define(Vector2i(0, 2))  #Wall Edge
	renderer.define(Vector2i(0, 1))  #Wall
	renderer.define(Vector2i(0, 0))  #Ground


func render():
	var filter = func(id: String): return DungeonLayoutNode.is_floor(id, floor)
	var rooms = layout.master_room_dict.keys().filter(filter)
	for room in rooms:
		render_room(room)
	renderer.render(map)


func teleport(new_floor: int):
	floor = new_floor
	clear()
	render()
	var room_id = layout.floor_entrys[floor]
	for stair in stairs_list:
		if stair.cur_room_id == room_id:
			Global.player.position = stairs_list[0].position
			break


func floor_up(new_floor: int) -> void:
	floor = new_floor
	clear()
	render()
	var previous_room = layout.master_room_dict[layout.floor_entrys[floor + 1]].uuid
	var room_rect = layout.master_room_dict[layout.to_start_map[previous_room]].room_rect
	var scaled_rect = Rect2i(room_rect)
	camera.position = map.map_to_local(scaled_rect.get_center())


func add_door(rect: Rect2i, room_id: String, id: String):
	var door_node = door.instantiate()
	door_node.position = Rect2(rect).get_center() * Vector2(map.tile_set.tile_size)
	door_node.rotation = deg_to_rad(90 if rect.size.x == door_size else 0)
	map.add_child(door_node)
	door_node.expand(rect)
	door_node.init(layout, room_id, id, data)


func place_in_room(scene: PackedScene, room: Rect2i):
	var scene_node = scene.instantiate()
	var room_rect = Rect2i(room).grow(-2)
	var x = rng.randi_range(room_rect.position.x, room_rect.position.x + room_rect.size.x)
	var y = rng.randi_range(room_rect.position.y, room_rect.position.y + room_rect.size.y)
	scene_node.position = map.map_to_local(Vector2i(x, y))
	map.add_child(scene_node)
	return scene_node


func place_chest(cur_room_rect: Rect2i, room: DungeonLayoutNode):
	if room.content.is_empty():
		return
	var chest = place_in_room(chest, cur_room_rect)
	chest.set_content(room.content)


func place_stairs(room: DungeonLayoutNode, connection: String):
	var stairs = place_in_room(stairs, room.room_rect.grow(-2))
	stairs.set_floor(room.uuid, connection)
	stairs_list.append(stairs)


func render_room(room: String):
	var door_save_area: int = 1

	var connection_tiles: Array[Vector2i] = []

	var room_node: DungeonLayoutNode = layout.master_room_dict[room]
	var room_rect: Rect2i = Rect2i(room_node.room_rect).grow(-3)

	var filter = func(conn: String):
		var id = layout.master_room_dict[conn].room_id
		return !connection_list.has(
			"%d_%d" % [min(room_node.room_id, id), max(room_node.room_id, id)]
		)

	var connections = room_node.connections.duplicate().filter(filter)
	for connection in room_node.connections:
		var id = layout.master_room_dict[connection].room_id
		connection_list.set(
			"%d_%d" % [min(room_node.room_id, id), max(room_node.room_id, id)], true
		)
		if !DungeonLayoutNode.is_floor(connection, room_node.floor_id):
			place_stairs(room_node, connection)
			continue
		var other = layout.master_room_dict[connection]
		var other_rect = Rect2i(other.room_rect)
		var between_rect = get_between_rect(room_rect, other_rect.grow(-3))
		var horizontal: bool
		if between_rect.size.x > between_rect.size.y:
			var center = between_rect.get_center()
			between_rect.size.x = door_size
			between_rect.position += center - between_rect.get_center()
			horizontal = true
		elif between_rect.size.x < between_rect.size.y:
			var center = between_rect.get_center()
			between_rect.size.y = door_size
			between_rect.position += center - between_rect.get_center()
			horizontal = false

		var horizontal_vector = Vector2i(horizontal, !horizontal)
		var w = between_rect.size.x + (horizontal_vector.x * 2)
		var h = between_rect.size.y + (horizontal_vector.y * 2)
		for x in w:
			for y in h:
				var point = Vector2i(x, y) - horizontal_vector
				if (
					(horizontal and (x == 0 or x == w - 1))
					or (!horizontal and (y == 0 or y == h - 1))
				):
					renderer.add_terrain(point + between_rect.position, Vector2i(0, 3))
					continue
				renderer.add_terrain(point + between_rect.position, Vector2i(0, 0))
		add_door(between_rect, room, connection)

	place_chest(room_rect, room_node)

	for x in room_rect.size.x + 6:
		for y in room_rect.size.y + 6:
			var current_point = Vector2i(x - 3, y - 3) + room_rect.position
			if room_rect.has_point(current_point):
				renderer.add_terrain(current_point, Vector2i(0, 0))
			else:
				if x == 0 or y == 0 or x == room_rect.size.x + 5 or y == room_rect.size.y + 5:
					renderer.add_terrain(current_point, Vector2i(0, 2))
				else:
					renderer.add_terrain(current_point, Vector2i(0, 1))

	for i in connection_tiles:
		renderer.add_terrain(i, Vector2i(0, 0))

	if room == layout.start_node:
		place_stairs(room_node, "outside")


func get_between_rect(room0: Rect2i, room1: Rect2i) -> Rect2i:
	var a1 = room0.position
	var a2 = room0.position + room0.size
	var b1 = room1.position
	var b2 = room1.position + room1.size

	var x1_min = min(a1.x, b1.x)
	var x1_max = max(a1.x, b1.x)
	var y1_min = min(a1.y, b1.y)
	var y1_max = max(a1.y, b1.y)

	var x2_min = min(a2.x, b2.x)
	var x2_max = max(a2.x, b2.x)
	var y2_min = min(a2.y, b2.y)
	var y2_max = max(a2.y, b2.y)

	var x_schnitt_min = max(x1_min, x2_min)
	var x_schnitt_max = min(x1_max, x2_max)
	var y_schnitt_min = max(y1_min, y2_min)
	var y_schnitt_max = min(y1_max, y2_max)

	var x = min(x_schnitt_min, x_schnitt_max)
	var y = min(y_schnitt_min, y_schnitt_max)
	var x_max = max(x_schnitt_min, x_schnitt_max)
	var y_max = max(y_schnitt_min, y_schnitt_max)
	return Rect2i(Vector2i(x, y), Vector2i(x_max - x, y_max - y))
