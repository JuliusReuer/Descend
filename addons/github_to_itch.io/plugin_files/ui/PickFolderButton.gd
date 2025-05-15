@tool
class_name PickFolderButton
extends Button

signal update(path: String)

@export var path_label: Label
@export var dialog: FileDialog


func _ready() -> void:
	dialog.dir_selected.connect(_update_path_label)


func _pressed() -> void:
	dialog.show()


func _update_path_label(dir: String):
	path_label.text = dir
	update.emit(dir)


func set_path(dir: String):
	path_label.text = dir
	dialog.current_dir = dir
