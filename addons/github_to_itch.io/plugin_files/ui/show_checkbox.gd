@tool
class_name ShowCheckbox
extends CheckBox


func _enter_tree() -> void:
	toggle(false)
	if !toggled.is_connected(toggle):
		toggled.connect(toggle)
	focus_mode = Control.FOCUS_NONE


func toggle(on: bool):
	var parent = get_parent()
	var children = parent.get_children()
	for child: Control in children:
		if child != self:
			child.visible = on

func update():
	toggled.emit(button_pressed)
