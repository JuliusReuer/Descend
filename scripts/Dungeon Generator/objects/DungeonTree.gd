class_name DungeonTree
enum DungeonTreeConnectionState { NOT_CONNECTED, CONNECTED, LOOP }

var edges: Array[Edge] = []
var vertices: Array[int] = []  #TODO: use Dictionary as Hash map


func _init(edge: Edge) -> void:
	add(edge)


func add(edge: Edge):
	edges.push_back(edge)
	vertices.push_back(edge.p0.dungeon_room_idx)
	vertices.push_back(edge.p1.dungeon_room_idx)


func is_edge_connected(edge: Edge) -> DungeonTreeConnectionState:
	var foundP0: bool = vertices.has(edge.p0.dungeon_room_idx)
	var foundP1: bool = vertices.has(edge.p1.dungeon_room_idx)

	if foundP0 and foundP1:
		return DungeonTreeConnectionState.LOOP
	elif foundP0 or foundP1:
		return DungeonTreeConnectionState.CONNECTED
	return DungeonTreeConnectionState.NOT_CONNECTED


func merge(tree: DungeonTree):
	edges.append_array(tree.edges)
	vertices.append_array(tree.vertices)
