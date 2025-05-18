extends Area2D

var in_collider:bool = false
@export var exit:SceneManagerOption
@export var enter:SceneManagerOption
@export var general:SceneManagerGeneralOption
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("enter") and in_collider:
		DungeonCache.inventory = Global.player.inventory
		SceneManager.change_scene("Main",exit.get_option(),enter.get_option(),general.get_option())

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		SignalBus.stairs_left.emit()
		in_collider = false


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		SignalBus.stairs_entered.emit()
		in_collider = true
