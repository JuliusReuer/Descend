class_name SceneManagerOption
extends Resource

## speed of fading out of the scene or fading into the scene in seconds.
@export var fade_speed: float = 1.0
## name of a shader pattern which is in addons/scene_manager/shader_patterns folder for fading out or fading into the scene. (if you use fade or an empty string, it causes a simple fade screen transition)
@export_enum("fade", "circle", "crooked_tiles", "curtains", "diagonal", "dirt", "horizontal", "pixel", "radial", "scribbles", "splashed_dirt", "squares", "vertical")
var fade_pattern: String = "fade"
## defines roughness of pattern's edges. (this value is between 0-1 and more near to 1, softer edges and more near to 0, harder edges)
@export_range(0, 1, 0.01) var smoothness: float = 1.0
## inverts the pattern.
@export var inverted: bool


func get_option():
	return SceneManager.create_options(fade_speed, fade_pattern, smoothness, inverted)
