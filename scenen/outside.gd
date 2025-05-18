extends Node2D
@export var bariere:CollisionShape2D

func _ready() -> void:
	Global.player.input_disabled = true
	bariere.disabled = true
	if !DungeonCache.has_seed:
		Global.player.velocity = Vector2(0,-20)
		await get_tree().create_timer(7,true,true,true).timeout
		Global.player.input_disabled = false
		bariere.disabled = false
	else:
		Global.player.position = Vector2(288,100)
		Global.player.input_disabled = false
		bariere.disabled = false
