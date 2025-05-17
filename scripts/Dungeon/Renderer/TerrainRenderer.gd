class_name TerrainRenderer


class PositionList:
	var terrain: Vector2i
	var list: Array[Vector2i]


var terrain_render: Dictionary[Vector2i,PositionList] = {}


func clear():
	terrain_render = {}


func define(terrain: Vector2i):
	if terrain_render.has(terrain):
		return
	terrain_render[terrain] = PositionList.new()
	terrain_render[terrain].terrain = terrain
	terrain_render[terrain].list = []


func add_terrain(pos: Vector2i, terrain: Vector2i):
	if !terrain_render.has(terrain):
		define(terrain)
	terrain_render[terrain].list.append(pos)


func render(layer: TileMapLayer):
	for terrain in terrain_render:
		BetterTerrain.set_cells(layer, terrain_render[terrain].list, terrain.y)
		BetterTerrain.update_terrain_cells(layer, terrain_render[terrain].list)
