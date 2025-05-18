class_name SceneManagerGeneralOption
extends Resource

## color for the whole transition.
@export var color: Color = Color(0, 0, 0)
## between this scene and next scene, there would be a gap which can take much longer that usual(default is 0) by your choice by changing this option.
@export var timeout: float = 0
## makes the scene behind the transition visuals clickable or not.
@export var clickable: bool = true
## if true, you can go back to current scene after changing scene to next scene by going to "back" scene which means previous scene.
@export var add_to_back: bool = true

func get_option():
	return SceneManager.create_general_options(color,timeout,clickable,add_to_back)
