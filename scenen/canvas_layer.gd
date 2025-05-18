extends CanvasLayer

@export var dungeon:Dungeon
@export var list:DungeonGeneratorList

@export var progr:ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.load_finished.connect(hide)
	dungeon.update.connect(update)
	list.next.connect(update)

func update():
	progr.value = dungeon.pipeline_idx+list.current_generator
	progr.max_value = len(dungeon.pipeline)+len(list.floors)
