class_name Chest
extends Node2D
var content: String
var collected: bool
var is_in_range:bool 

func set_content(id: String)->void:
	content = id

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open") and is_in_range:
		Global.player.add_collectable(content)
		

func _on_open_range_body_entered(body: Node2D) -> void:
	if body is Player: 
		SignalBus.chest_entered.emit()
		is_in_range = true
