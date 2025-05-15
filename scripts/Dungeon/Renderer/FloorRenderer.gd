class_name FloorRenderer
extends DungeonPipeline

@export var floor: int = 0
@export var map: TileMapLayer
#@export var layout_scale: float = 1
@export var camera: Camera2D
@export var door: PackedScene
var door_size = 4

var layout: DungeonLayout
var data: DungeonData
var renderer: TerrainRenderer = TerrainRenderer.new()


func to_dict(arr: Array[Vector2i]) -> Dictionary[Vector2i,bool]:
	var dict: Dictionary[Vector2i,bool] = {}
	for val in arr:
		dict.set(val, true)
	return dict


func start(dungeon: Dungeon):
	layout = dungeon.layout
	data = dungeon.data
	teleport(0)


func clear():
	map.clear()
	for child in map.get_children():
		map.remove_child(child)
	renderer.define(Vector2i(0, 0))


func teleport(new_floor: int):
	floor = new_floor
	clear()

	var filter = func(id: String): return DungeonLayoutNode.is_floor(id, floor)
	var rooms = layout.master_room_dict.keys().filter(filter)
	for room in rooms:
		render_room(room)

	var room_rect = layout.master_room_dict[layout.floor_entrys[floor]].room_rect
	var scaled_rect = Rect2i(room_rect)  #Rect2i(room_rect.position / layout_scale, room_rect.size / layout_scale)
	camera.position = map.map_to_local(scaled_rect.get_center())
	renderer.render(map)


func add_door(rect: Rect2i, room_id: String, id: String):
	var door_node = door.instantiate()
	door_node.position = Rect2(rect).get_center() * Vector2(map.tile_set.tile_size)
	door_node.rotation = deg_to_rad(90 if rect.size.x == door_size else 0)
	map.add_child(door_node)
	door_node.expand(rect)
	door_node.init(layout, room_id, id, data)


func render_room(room: String):
	var room_node: DungeonLayoutNode = layout.master_room_dict[room]
	var room_rect: Rect2i = Rect2i(room_node.room_rect).grow(-3)
	var start = Time.get_unix_time_from_system()
	var connection_tiles: Array[Vector2i] = []

	for connection in room_node.connections:
		if !DungeonLayoutNode.is_floor(connection, room_node.floor_id):
			continue
		var other = layout.master_room_dict[connection]
		var other_rect = Rect2i(other.room_rect)
		var between_rect = get_between_rect(room_rect, other_rect.grow(-3))
		if between_rect.size.x > between_rect.size.y:
			var center = between_rect.get_center()
			between_rect.size.x = door_size
			between_rect.position += center - between_rect.get_center()
		elif between_rect.size.x < between_rect.size.y:
			var center = between_rect.get_center()
			between_rect.size.y = door_size
			between_rect.position += center - between_rect.get_center()
		for x in between_rect.size.x:
			for y in between_rect.size.y:
				renderer.add_terrain(Vector2i(x, y) + between_rect.position, Vector2i(0, 0))
		add_door(between_rect, room, connection)

	for x in room_rect.size.x:
		for y in room_rect.size.y:
			renderer.add_terrain(Vector2i(x, y) + room_rect.position, Vector2i(0, 0))

	for i in connection_tiles:
		renderer.add_terrain(i, Vector2i(0, 0))


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
