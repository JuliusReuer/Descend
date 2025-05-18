class_name Stairs
extends Node2D

@export var exit:SceneManagerOption
@export var enter:SceneManagerOption
@export var general:SceneManagerGeneralOption

var cur_room_id: String
var other_room_id: String
var is_in_range:bool
var renderer:FloorRenderer
@onready var sprite: Sprite2D = $Sprite2D


func set_floor(current_room: String, id: String) -> void:
	cur_room_id = current_room
	other_room_id = id
	if other_room_id == "outside":
		sprite.frame = 0
		return
	var dir: int = DungeonLayoutNode.get_floor(current_room) - DungeonLayoutNode.get_floor(id)
	if dir == 1:
		sprite.frame = 0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("enter") and is_in_range:
		if sprite.frame == 0:
			if other_room_id == "outside":
				DungeonCache.inventory = Global.player.inventory
				SceneManager.change_scene("Outside",exit.get_option(),enter.get_option(),general.get_option())
				return #TODO: Load Outside
			renderer.floor_up(DungeonLayoutNode.get_floor(other_room_id))
		else:
			renderer.teleport(DungeonLayoutNode.get_floor(other_room_id))

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		SignalBus.stairs_entered.emit()
		is_in_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		SignalBus.stairs_left.emit()
		is_in_range = false
