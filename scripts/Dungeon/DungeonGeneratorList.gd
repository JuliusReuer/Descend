class_name DungeonGeneratorList
extends DungeonPipeline

var floors: Array[DungeonGenerator]
var current_generator: int = 0
@export var generation_seed: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	rng.seed = generation_seed
	for node in get_children():
		if node is DungeonGenerator:
			floors.append(node)
			node.set_seed(rng.randi())


func _process(_delta: float) -> void:
	if step_finished:
		return
	if !floors[current_generator]._is_generating:
		floors[current_generator].generate_dungeon()
	else:
		if (
			floors[current_generator]._current_generation_state
			== DungeonGenerator.GenerationCycleState.DISCARD_SMALL_ROOMS
		):
			if current_generator + 1 < len(floors):
				current_generator += 1
		if floors[current_generator].is_done():
			step_finished = true
