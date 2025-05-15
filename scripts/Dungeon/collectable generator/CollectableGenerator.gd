class_name CollectableGenerator
extends DungeonPipeline

@export var mid_game_floor: int = 5

@export var end_game_floor: int = 20

@export var abilitys: Array[Ability]
@export var items: Array[CollectableItem]
@export var upgrades: Array[Upgrade]
@export var treasures: Array[Treasure]

var layout: DungeonLayout
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var important_spots: Array[String] = []  # Treasure / Upgrades / Abilities
var ability_check: Dictionary[String,String] = {}
var item_spots: Array[String] = []

var block_door: Array[String] = []

#region Resulting Lists
var door_key_list: Dictionary[String,String] = {}  #Door,Key
var key_placements: Array[String] = []
var item_placements: Dictionary[String,String] = {}  #Item_id,Room
var ability_placements: Dictionary[String,String] = {}  #Ability_id,Room
var upgrade_placements: Dictionary[String,String] = {}  #Room,Upgrade_id
var treasure_placements: Dictionary[String,String] = {}  #Room,Treasure_id
#endregion

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
		if connections.size() > 2:
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

	if possible_node_placing.is_empty():
		return ""

	return possible_node_placing[rng.randi_range(0, len(possible_node_placing) - 1)]


func generate_node_for_placeable(placeable: Placeable) -> String:
	var possible_ability_placing: Array[String] = layout.master_room_dict.duplicate().keys()
	var game_stage_filter = filter_generator(placeable)
	possible_ability_placing = possible_ability_placing.filter(game_stage_filter)
	for node in block_door:
		possible_ability_placing.erase(node)

	var filter_important = important_spots.duplicate().filter(game_stage_filter)

	var placeable_node: String = ""  # redefine Spread
	if len(filter_important) > 0 and rng.randf() <= (placeable.spread / 100):
		# Place on important node -> can't be a door
		placeable_node = filter_important[rng.randi_range(0, len(filter_important) - 1)]
		important_spots.erase(placeable_node)
	else:  #Place Random -> can be door so filter on block door + add to block Door
		if len(possible_ability_placing) == 0:
			return ""
		placeable_node = possible_ability_placing[rng.randi_range(
			0, len(possible_ability_placing) - 1
		)]
		block_door.append(placeable_node)
	return placeable_node


func filter_generator(placeable: Placeable) -> Callable:
	var game_stage_filter = func(node_name: String):
		var time = placeable.game_play_time_stamp
		if time & 1 == 1:
			if DungeonLayoutNode.get_floor(node_name) < mid_game_floor:
				return true
		if time & 2 == 2:
			var cur_floor = DungeonLayoutNode.get_floor(node_name)
			if cur_floor >= mid_game_floor and cur_floor < end_game_floor:
				return true
		if time & 4 == 4:
			if DungeonLayoutNode.get_floor(node_name) >= end_game_floor:
				return true
		return false
	return game_stage_filter


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
			ability_check.set(branch[1], leaf)
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

	var place_important = func(treasure: Treasure): return treasure.generate_in_important_rooms
	var important_treasure = treasures.duplicate().filter(place_important)
	for spot in important_spots:
		treasure_placements.set(
			spot, important_treasure[rng.randi_range(0, len(important_treasure) - 1)].id
		)
	important_spots.clear()
	for spot in item_spots:
		treasure_placements.set(
			spot, important_treasure[rng.randi_range(0, len(important_treasure) - 1)].id
		)
	item_spots.clear()

	for treasure in treasures:
		add_treasure(treasure)

	for check in ability_check:
		var leaf_node = ability_check[check]
		if ability_placements.values().has(leaf_node):
			#cearfully Choose not to lock the player out
			pass  #get all acessable abilitys bevore this one
			#-Try Forcing Ability Door
			#1. get ability_id in leaf
			#2. get all gate notes for that ability
			#3. get all the notes that are not the path to the start and walk them
			#4. exclude all the got nodes from the list.
			#5. check remaining nodes for abilitys
			#6. if the list is empty generate door instead of ability gate
			#   and place a key in the remaining rooms
			#7. else pick a random abilility from the remaing nodes list
		else:
			#just choos a random ability -> the player can come back later
			var ability_id = ability_placements.keys()[rng.randi_range(
				0, len(ability_placements.keys()) - 1
			)]
			door_key_list.set(check, ability_placements[ability_id])
	finished.emit()


func add_key(leaf: String):
	var door_pos = generate_gate(leaf)
	door_key_list.set(door_pos, leaf)
	block_door.append(door_pos)


func add_ability(ability: Ability):
	for i in ability.amount:
		var ability_node: String = generate_node_for_placeable(ability)

		for gate_id in ability.gates:
			var gate = generate_gate(ability_node)
			block_door.append(gate)
			door_key_list.set(gate, ability_node)
		ability_placements.set(ability.id + (("#%d" % i) if i > 0 else ""), ability_node)


func add_item(item: CollectableItem):
	if item.rarity == CollectableItem.Rarity.UNIQUE:
		var filter = filter_generator(item)
		var possible_placements: Array[String] = item_spots.duplicate().filter(filter)
		if len(possible_placements) > 0:
			var item_node = possible_placements[rng.randi_range(0, len(possible_placements) - 1)]
			item_placements.set(item.id, item_node)
			item_spots.erase(item_node)
			return
		item.amount = 1
	for i in item.amount:
		var item_node: String = generate_node_for_placeable(item)

		item_placements.set(item.id + (("#%d" % i) if i > 0 else ""), item_node)


func add_upgrade(upgrade: Upgrade):
	for i in upgrade.amount:
		#Try Placing Upgrades in item_spots
		var filter = filter_generator(upgrade)
		var possible_placements: Array[String] = item_spots.duplicate().filter(filter)
		if len(possible_placements) > 0 and rng.randf() <= (upgrade.item_spot_chance / 100):
			var upgrade_place_node = possible_placements[rng.randi_range(
				0, len(possible_placements) - 1
			)]
			upgrade_placements.set(upgrade_place_node, upgrade.id)
			item_spots.erase(upgrade_place_node)
			continue
		var upgrade_node: String = generate_node_for_placeable(upgrade)
		upgrade_placements.set(upgrade_node, upgrade.id)


func add_treasure(treasure: Treasure):
	for i in treasure.amount:
		var treasure_node: String = generate_node_for_placeable(treasure)
		treasure_placements.set(treasure_node, treasure.id)
