extends AnimationTree

var velocity:Vector2

func _process(delta: float) -> void:
	if get_parent() is Player:
		velocity = get_parent().velocity
