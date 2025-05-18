extends Label

var tween: Tween

func _ready() -> void:
	SignalBus.stairs_entered.connect(show_label)
	SignalBus.stairs_left.connect(hide_label)
	modulate = Color.TRANSPARENT


func show_label() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)


func hide_label() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
