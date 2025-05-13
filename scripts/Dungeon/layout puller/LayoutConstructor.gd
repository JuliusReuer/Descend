class_name LayoutConstructor
extends DungeonPipeline

var generation_list: DungeonGeneratorList
var dungeon_layout: DungeonLayout


func start(dungeon: Dungeon):
	dungeon_layout = DungeonLayout.new()
	if dungeon.pipeline[dungeon.pipeline_idx - 1] is DungeonGeneratorList:
		generation_list = dungeon.pipeline[dungeon.pipeline_idx - 1]

	dungeon_layout.start_node = DungeonLayoutNode.id_str % [0, generation_list.floors[0].start_idx]

	for dungeon_floor_id in len(generation_list.floors):
		var dungeon_floor = generation_list.floors[dungeon_floor_id]
		for room_id in len(dungeon_floor.rooms):
			dungeon_layout.add(dungeon_floor, dungeon_floor_id, room_id)

	set_to_start_path()
	#set_to_finish_path()

	dungeon.layout = dungeon_layout
	finished.emit()


func compute_back_path(start_room: String) -> Dictionary[String,String]:
	var came_from: Dictionary[String,String] = {}
	var visited := {}
	var queue := [start_room]

	came_from[start_room] = ""  # end of chain

	while not queue.is_empty():
		var current = queue.pop_front()
		if !dungeon_layout.master_room_dict.has(current):
			continue
		if visited.has(current):
			continue
		visited[current] = true

		for neighbor in dungeon_layout.master_room_dict[current].connections:
			if not visited.has(neighbor):
				queue.append(neighbor)
				if not came_from.has(neighbor):
					came_from[neighbor] = current  # this is how you walked back

	return came_from  # maps room_id -> previous room_id


func set_to_start_path():
	var came_from = compute_back_path(dungeon_layout.start_node)
	dungeon_layout.to_start_map = came_from


func set_to_finish_path():
	var came_from = compute_back_path(dungeon_layout.finish_node)
	dungeon_layout.to_finish_map = came_from
