class_name FloorRenderer
extends DungeonPipeline
var layout: DungeonLayout
var renderer: TerrainRenderer = TerrainRenderer.new()
@export var floor: int = 0
@export var map: TileMapLayer
@export var layout_scale: float = 1
@export var camera: Camera2D

var _is_rendering: bool
var render_id: int


func to_dict(arr: Array[Vector2i]) -> Dictionary[Vector2i,bool]:
	var dict: Dictionary[Vector2i,bool] = {}
	for val in arr:
		dict.set(val, true)
	return dict


func start(dungeon: Dungeon):
	layout = dungeon.layout
	_is_rendering = true


func render_room(room: String):
	var room_node = layout.master_room_dict[room]
	var start = Time.get_unix_time_from_system()
	var width = int(room_node.room_rect.size.x / layout_scale) - 2
	var height = int(room_node.room_rect.size.y / layout_scale) - 2
	var base = Vector2i(
		1 + room_node.room_rect.position.x / layout_scale,
		1 + room_node.room_rect.position.y / layout_scale
	)
	for x in width:
		for y in height:
			renderer.add_terrain(Vector2i(x, y)+base, Vector2i(0, 0))


func _process(delta: float) -> void:
	if !_is_rendering:
		return
	if render_id >= len(layout.master_room_dict.keys()):
		var room_rect = layout.master_room_dict[layout.start_node].room_rect
		var scaled_rect = Rect2i(room_rect.position / layout_scale, room_rect.size / layout_scale)
		camera.position = map.map_to_local(scaled_rect.get_center())
		renderer.render(map)
		_is_rendering = false
	else:
		var room = layout.master_room_dict.keys()[render_id]
		if DungeonLayoutNode.get_floor(room) == floor:
			render_room(room)
		render_id += 1
