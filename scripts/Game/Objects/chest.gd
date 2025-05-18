class_name Chest
extends Node2D
var content: String
var collected: bool
var is_in_range: bool

@onready var sprite: Sprite2D = $Sprite2D


func set_content(id: String) -> void:
	content = id


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open") and is_in_range and !collected:
		Global.player.add_collectable(content)
		SignalBus.collected.emit(content)
		SignalBus.chest_left.emit()
		sprite.frame = 1
		collected = true


func _on_open_range_body_entered(body: Node2D) -> void:
	if body is Player and !collected:
		SignalBus.chest_entered.emit()
		is_in_range = true


func _on_open_range_body_exited(body: Node2D) -> void:
	if body is Player and !collected:
		SignalBus.chest_left.emit()
		is_in_range = false
