class_name CollectableGenerator
extends DungeonPipeline

var layout: DungeonLayout

var key_spots: Array[String] = []
var important_spots: Array[String] = []  #Treasure / Upgrads / Ability
var ability_check: Array[String] = []


func start(dungeon: Dungeon):
	layout = dungeon.layout
	generate()


func generate():
	for leaf in layout.dead_end:
		var branch = get_branch_path(leaf)
		if len(branch) <= 2:
			key_spots.append(leaf)
		else:
			important_spots.append(leaf)
			ability_check.append(branch[1])


func get_branch_path(start_node: String) -> Array[String]:
	var visited: Array[String] = []
	var cur_node: String = start_node
	while len(layout.master_room_dict[cur_node].connections) <= 2:
		visited.append(cur_node)
		if visited.has(layout.master_room_dict[cur_node].connections[0]):
			cur_node = layout.master_room_dict[cur_node].connections[1]
		else:
			cur_node = layout.master_room_dict[cur_node].connections[0]
	return visited
