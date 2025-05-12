class_name DungeonSolver
extends Node2D

var _dungeon: DungeonGenerator

var _need_all_keys: bool
var _forced_path: Array[int]


func _init() -> void:
	pass


func solve(save_shortest_route = false):
	pass


func set_need_all_keys(need_all_keys: bool):
	pass


func _has_discovered(room_idx: int):
	pass


func _save_shortest_route():
	pass


func _solove_step():
	pass
