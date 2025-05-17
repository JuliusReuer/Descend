class_name Player
extends CharacterBody2D

@export var speed: float = 300
@export var accel: float = 2
@export var inventory: Dictionary[String,int] = {}


func _ready() -> void:
	Global.player = self


func get_input() -> Vector2:
	var input: Vector2
	input.x = Input.get_axis("left", "right")
	input.y = Input.get_axis("up", "down")
	return input.normalized()


func _physics_process(delta: float) -> void:
	var player_input = get_input()
	velocity = lerp(velocity, player_input * speed, delta * accel)
	move_and_slide()
