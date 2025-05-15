class_name TerrainRenderer


class PositionList:
	var terrain: Vector2i
	var list: Array[Vector2i]


var terrain_render: Dictionary[Vector2i,PositionList] = {}
var _used_cells: Dictionary[Vector2i,bool] = {}
var _used_rect: Rect2i


func get_used_rect() -> Rect2i:
	return _used_rect


func get_used_cells() -> Dictionary[Vector2i,bool]:
	return _used_cells


func _add_cell(pos: Vector2i):
	if len(_used_cells.keys()) == 0:
		_used_rect = Rect2i(pos, Vector2i.ZERO)
	else:
		_used_rect = _used_rect.expand(pos)
	_used_cells.set(pos, true)


func define(terrain: Vector2i):
	terrain_render[terrain] = PositionList.new()
	terrain_render[terrain].terrain = terrain
	terrain_render[terrain].list = []


func add_terrain(pos: Vector2i, terrain: Vector2i):
	if !terrain_render.has(terrain):
		define(terrain)
	terrain_render[terrain].list.append(pos)
	#_add_cell(pos)


func render(layer: TileMapLayer):
	for terrain in terrain_render:
		layer.set_cells_terrain_connect(terrain_render[terrain].list, terrain.x, terrain.y)
