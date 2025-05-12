class_name DungeonPipeline
extends Node2D

signal finished
var step_finished: bool = false:
	set(value):
		if value:
			finished.emit()
		step_finished = value


func start(_dungeon: Dungeon):
	pass
