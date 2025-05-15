@tool
extends HBoxContainer
@export var panel: PanelContainer

var show_label: Label


func _ready() -> void:
	var children = get_children()
	if len(children) != 2:
		push_warning("Here Should be a Label as a Child")
		return
	for child in children:
		if child != panel:
			if child is Label:
				show_label = child
	if !show_label:
		return
	show_label.modulate = Color.TRANSPARENT
	panel.mouse_entered.connect(hover)
	panel.mouse_exited.connect(unhover)


var label_opacity_tween: Tween


func hover():
	if label_opacity_tween and label_opacity_tween.is_running():
		label_opacity_tween.kill()
	label_opacity_tween = create_tween()
	label_opacity_tween.tween_property(show_label, "modulate", Color.WHITE, 0.125)


func unhover():
	if label_opacity_tween and label_opacity_tween.is_running():
		label_opacity_tween.kill()
	label_opacity_tween = create_tween()
	label_opacity_tween.tween_property(show_label, "modulate", Color.TRANSPARENT, 0.5)
