class_name DungeonGeneratorList
extends DungeonPipeline

signal next

@export var generation_seed: int = 0
var floors: Array[DungeonGenerator]
var current_generator: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _is_running = false


func _ready() -> void:
	rng.seed = generation_seed
	for node in get_children():
		if node is DungeonGenerator:
			floors.append(node)


func start(dungeon: Dungeon):
	generation_seed = dungeon.rng.randi()
	rng.seed = generation_seed
	for dungeon_floor in floors:
		dungeon_floor.set_seed(rng.randi())
	_is_running = true


func _process(_delta: float) -> void:
	if step_finished or !_is_running:
		return
	if !floors[current_generator]._is_generating:
		next.emit()
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
