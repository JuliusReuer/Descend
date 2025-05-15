extends SpinBox

@export var renderer:FloorRenderer

func _on_value_changed(value: float) -> void:
	renderer.teleport(value)
