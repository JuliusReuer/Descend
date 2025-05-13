class_name Ability
extends Placeable

@export var gates: int = 5
@export_group("Progress Ability", "progress_")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var progress_enabled: bool
@export var progress_progressable: Array[Ability]
