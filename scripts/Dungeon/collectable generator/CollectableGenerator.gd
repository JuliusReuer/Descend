class_name CollectableGenerator
extends DungeonPipeline

@export var mid_game_floor:int = 5

@export var end_game_floor:int = 20

@export var abilitys:Array[Ability]
#@export var item:Array[Item]
#@export var upgrad:Array[Upgrade]
#@export var treasure:Array[Treasure]

var layout: DungeonLayout
var rng:RandomNumberGenerator = RandomNumberGenerator.new()

var key_list: Dictionary[String,String] = {}
var ability_list: Dictionary[String,String] = {}
var important_spots: Array[String] = []  # Treasure / Upgrades / Abilities
var ability_check: Array[String] = []
var item_spots:Array[String] = []


func start(dungeon: Dungeon) -> void:
	layout = dungeon.layout
	rng.seed = dungeon.rng.randi()
	generate()


func get_path_to_root(came_from: Dictionary[String,String], start_room: String) -> Array[String]:
	var path:Array[String] = []
	var current = start_room
	while current != null:
		path.append(current)
		current = came_from.get(current, null)
	return path


func generate() -> void:
	for leaf in layout.dead_end:
		var branch = get_branch_path(leaf)
		if branch.size() <= 2:
			add_key(leaf)
		else:
			important_spots.append(leaf)
			ability_check.append(branch[1])
			item_spots.append(branch[2])
	
	for ability in abilitys:
		add_ability(ability)

func get_branch_path(start_node: String) -> Array[String]:
	var visited: Array[String] = []
	var cur_node: String = start_node

	while cur_node != "" and cur_node in layout.master_room_dict:
		if visited.has(cur_node):
			break  # Avoid loops
		visited.append(cur_node)

		var connections = layout.master_room_dict[cur_node].connections
		if connections.size() != 2:
			break  # End of simple branch

		# Choose next node not already visited
		var next_node = connections[0] if not visited.has(connections[0]) else connections[1]
		cur_node = next_node

	return visited


func add_key(leaf: String):
	var queue:Array[String] = [leaf]
	var possible_node_placing:Array[String] = layout.master_room_dict.duplicate().keys()
	while queue.is_empty():
		var current = queue.pop_back()
		var path = get_path_to_root(layout.to_start_map, current)
		for node in path:
			if key_list.has(node):
				queue.append(key_list[node])
			possible_node_placing.erase(node)
	
	var door_pos = possible_node_placing[rng.randi_range(0,len(possible_node_placing)-1)]
	key_list.set(door_pos, leaf)


func add_ability(ability:Ability):
	var possible_node_placing:Array[String] = layout.master_room_dict.duplicate().keys()
	var game_stage_filter = func(node_name:String):
		match ability.game_play_time_stamp:
			0:
				return DungeonLayoutNode.get_floor(node_name) < mid_game_floor
			1:
				var cur_floor = DungeonLayoutNode.get_floor(node_name)
				return cur_floor >= mid_game_floor and cur_floor < end_game_floor
			2:
				return DungeonLayoutNode.get_floor(node_name) >= end_game_floor
	possible_node_placing.filter(game_stage_filter)
	print(possible_node_placing)
	#for 
