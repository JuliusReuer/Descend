class_name TerrainRenderer


class PositionList:
	var terrain: Vector2i
	var list: Array[Vector2]


var terrain_render: Dictionary[Vector2i,PositionList] = {}


func add_terrain(pos: Vector2i, terrain: Vector2i):
	if !terrain_render.has(terrain):
		terrain_render[terrain] = PositionList.new()
		terrain_render[terrain].terrain = terrain
		terrain_render[terrain].list = []
	terrain_render[terrain].list.append(pos)


func render(layer: TileMapLayer):
	pass
