extends SpinBox

@export var renderer: FloorRenderer


func _on_value_changed(new_value: float) -> void:
	renderer.teleport(int(new_value))
