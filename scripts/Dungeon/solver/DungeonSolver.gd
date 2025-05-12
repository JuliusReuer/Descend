class_name DungeonSolver
extends DungeonPipeline

var floors: Array[DungeonGenerator]
var _is_solving = false
var _is_solved = false


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if _is_solved:
		return
	if !_is_solving:
		var list_finished: bool = true
		for dungeon_floor in floors:
			if !dungeon_floor.is_done():
				list_finished = false
		if list_finished:
			_is_solving = true
