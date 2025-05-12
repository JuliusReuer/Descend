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

	dungeon.layout = dungeon_layout
	finished.emit()
