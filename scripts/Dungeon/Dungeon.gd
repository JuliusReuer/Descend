class_name Dungeon
extends Node2D

signal finished
signal update

@export var dungeon_seed: int
@export var debug:bool
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var layout: DungeonLayout
var data: DungeonData

var pipeline: Array[DungeonPipeline]
var pipeline_idx: int = 0

@export var exit:SceneManagerOption
@export var entered:SceneManagerOption
@export var general:SceneManagerGeneralOption


func _ready() -> void:
	rng.seed = dungeon_seed if debug else DungeonCache.get_seed()

	for node in get_children():
		if node is DungeonPipeline:
			pipeline.append(node)
	pipeline[0].finished.connect(pipeline_continiue)
	pipeline[pipeline_idx].start(self)


func pipeline_continiue():
	update.emit()
	pipeline[pipeline_idx].finished.disconnect(pipeline_continiue)
	if pipeline_idx + 1 < len(pipeline):
		pipeline_idx += 1
		pipeline[pipeline_idx].finished.connect(pipeline_continiue)
		pipeline[pipeline_idx].start(self)
	else:
		finished.emit()
		SceneManager.change_scene("",exit.get_option(),entered.get_option(),general.get_option())
		var animation:Callable = func()->void:
			SignalBus.load_finished.emit()
		SceneManager.fade_out_finished.connect(animation)
