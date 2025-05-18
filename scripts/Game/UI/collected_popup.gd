extends VBoxContainer

var prefix: String = "You collected "

var tween: Tween
var timer: float

@onready var label: RichTextLabel = %ItemLabel


func _ready() -> void:
	SignalBus.collected.connect(show_popup)
	modulate = Color.TRANSPARENT


func show_popup(id: String) -> void:
	label.text = prefix + PlaceableLookup.get_placeable_name(id)
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	tween.tween_property(self, "timer", 1, 3).from(0)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
