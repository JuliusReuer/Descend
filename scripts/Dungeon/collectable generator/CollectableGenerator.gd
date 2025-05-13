class_name CollectableGenerator
extends DungeonPipeline

@export var mid_game_floor: int = 5

@export var end_game_floor: int = 20

@export var abilitys: Array[Ability]
@export var items: Array[Item]
@export var upgrades: Array[Upgrade]
@export var treasures: Array[Treasure]

var layout: DungeonLayout
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var important_spots: Array[String] = []  # Treasure / Upgrades / Abilities
var ability_check: Array[String] = []
var item_spots: Array[String] = []

var block_door: Array[String] = []
var key_placements: Array[String] = []
var item_placements:Dictionary[String,String] = {} #Item_id,Room
var ability_placements: Dictionary[String,String] = {}  #Ability_id,Room
var door_key_list: Dictionary[String,String] = {}  #Door,Key

#region Utill


func get_path_to_root(came_from: Dictionary[String,String], start_room: String) -> Array[String]:
	var path: Array[String] = []
	var current = start_room
	while current != null:
		path.append(current)
		current = came_from.get(current, null)
	return path


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


func generate_gate(key_node: String) -> String:
	var queue: Array[String] = [key_node]
	var possible_node_placing: Array[String] = layout.master_room_dict.duplicate().keys()
	while not queue.is_empty():
		var current = queue.pop_back()
		var path = get_path_to_root(layout.to_start_map, current)
		for node in path:
			if door_key_list.has(node):
				queue.append(door_key_list[node])
			possible_node_placing.erase(node)
	for node in block_door:
		possible_node_placing.erase(node)
	return possible_node_placing[rng.randi_range(0, len(possible_node_placing) - 1)]


#endregion


func start(dungeon: Dungeon) -> void:
	layout = dungeon.layout
	rng.seed = dungeon.rng.randi()
	generate()


func generate() -> void:
	for leaf in layout.dead_end:
		var branch = get_branch_path(leaf)
		if branch.size() <= 2:
			key_placements.append(leaf)
		else:
			important_spots.append(leaf)
			ability_check.append(branch[1])
			block_door.append(branch[1])
			item_spots.append(branch[2])
			block_door.append(branch[2])
		block_door.append(leaf)

	for key_node in key_placements:
		add_key(key_node)

	for ability in abilitys:
		add_ability(ability)

	for item in items:
		add_item(item)

	for upgrade in upgrades:
		add_upgrade(upgrade)

	for spot in important_spots:
		pass  # fill rest of important spots with random treasures

	for treasure in treasures:
		pass  # spread treasures trough out the dungeon
	
	finished.emit()


func add_key(leaf: String):
	var door_pos = generate_gate(leaf)
	door_key_list.set(door_pos, leaf)
	block_door.append(door_pos)


func add_ability(ability: Ability):
	var possible_ability_placing: Array[String] = layout.master_room_dict.duplicate().keys()
	var game_stage_filter = func(node_name: String):
		match ability.game_play_time_stamp:
			0:
				return DungeonLayoutNode.get_floor(node_name) < mid_game_floor
			1:
				var cur_floor = DungeonLayoutNode.get_floor(node_name)
				return cur_floor >= mid_game_floor and cur_floor < end_game_floor
			2:
				return DungeonLayoutNode.get_floor(node_name) >= end_game_floor
	possible_ability_placing = possible_ability_placing.filter(game_stage_filter)
	for node in block_door:
		possible_ability_placing.erase(node)

	var filter_important = important_spots.duplicate().filter(game_stage_filter)

	var ability_node: String = ""
	if len(filter_important) > 0 and rng.randi_range(0, max(ability.spread, 0)) == 0:
		#Place on important -> cant bee Door
		ability_node = filter_important[rng.randi_range(0, len(filter_important) - 1)]
		important_spots.erase(ability_node)
	else:  #Place Random -> can be door so filter on block door + add to block Door
		ability_node = possible_ability_placing[rng.randi_range(
			0, len(possible_ability_placing) - 1
		)]
		block_door.append(ability_node)

	for gate_id in ability.gates:
		var gate = generate_gate(ability_node)
		block_door.append(gate)
		door_key_list.set(gate, ability_node)
	ability_placements.set(ability.id, ability_node)


func add_item(item:Item):
	var possible_ability_placing: Array[String] = layout.master_room_dict.duplicate().keys()
	var game_stage_filter = func(node_name: String):
		match item.game_play_time_stamp:
			0:
				return DungeonLayoutNode.get_floor(node_name) < mid_game_floor
			1:
				var cur_floor = DungeonLayoutNode.get_floor(node_name)
				return cur_floor >= mid_game_floor and cur_floor < end_game_floor
			2:
				return DungeonLayoutNode.get_floor(node_name) >= end_game_floor
	possible_ability_placing = possible_ability_placing.filter(game_stage_filter)
	for node in block_door:
		possible_ability_placing.erase(node)

	var filter_important = important_spots.duplicate().filter(game_stage_filter)
	
	var item_node: String = ""
	if len(filter_important) > 0 and rng.randi_range(0, max(item.spread, 0)) == 0:
		#Place on important -> cant bee Door
		item_node = filter_important[rng.randi_range(0, len(filter_important) - 1)]
		important_spots.erase(item_node)
	else:  #Place Random -> can be door so filter on block door + add to block Door
		item_node = possible_ability_placing[rng.randi_range(
			0, len(possible_ability_placing) - 1
		)]
		block_door.append(item_node)
	
	item_placements.set(item.id,item_node)


func add_upgrade(upgrade:Upgrade):
	pass
