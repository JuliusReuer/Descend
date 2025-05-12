class_name Dungeon
extends Node2D

signal finished

var layout: DungeonLayout

var pipeline: Array[DungeonPipeline]
var pipeline_idx: int = 0


func _ready() -> void:
	for node in get_children():
		if node is DungeonPipeline:
			pipeline.append(node)
	pipeline[0].finished.connect(pipeline_continiue)
	pipeline[pipeline_idx].start(self)


func pipeline_continiue():
	pipeline[pipeline_idx].finished.disconnect(pipeline_continiue)
	if pipeline_idx + 1 < len(pipeline):
		pipeline_idx += 1
		pipeline[pipeline_idx].finished.connect(pipeline_continiue)
		pipeline[pipeline_idx].start(self)
	else:
		finished.emit()
