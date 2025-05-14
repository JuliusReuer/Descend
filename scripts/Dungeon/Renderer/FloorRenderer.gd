class_name FloorRenderer
extends DungeonPipeline
var layout: DungeonLayout
var renderer: TerrainRenderer = TerrainRenderer.new()
@export var floor: int = 0
@export var map: TileMapLayer
@export var layout_scale: float = 1
@export var camera: Camera2D


func to_dict(arr: Array[Vector2i]) -> Dictionary[Vector2i,bool]:
	var dict: Dictionary[Vector2i,bool] = {}
	for val in arr:
		dict.set(val, true)
	return dict


func start(dungeon: Dungeon):
	layout = dungeon.layout
	render()
	var room_rect = layout.master_room_dict[layout.start_node].room_rect
	var scaled_rect = Rect2i(room_rect.position / layout_scale, room_rect.size / layout_scale)
	camera.position = map.map_to_local(scaled_rect.get_center())


func render():
	for room in layout.master_room_dict:
		if DungeonLayoutNode.get_floor(room) == floor:
			render_room(room)
	var fill = get_floud_fill(renderer.get_used_rect())
	map.set_cells_terrain_connect(fill, 0, 1)


func render_room(room: String):
	var room_node = layout.master_room_dict[room]
	for x in int(room_node.room_rect.size.x / layout_scale) - 2:
		for y in int(room_node.room_rect.size.y / layout_scale) - 2:
			var pos = Vector2i(
				x + 1 + room_node.room_rect.position.x / layout_scale,
				y + 1 + room_node.room_rect.position.y / layout_scale
			)
			renderer.add_terrain(pos, Vector2i(0, 0))


func get_floud_fill(area: Rect2i):
	var used = renderer.get_used_cells()
	for x in area.size.x:
		for y in area.size.y:
			var point: Vector2i = area.position + Vector2i(x, y)
			if !used.has(point):
				renderer.add_terrain(point, Vector2i(0, 1))
