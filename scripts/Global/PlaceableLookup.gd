extends Node

var _lookup: Dictionary[String,Placeable]


func _ready() -> void:
	var queue = ["res://resources/"]
	while !queue.is_empty():
		var element = queue.pop_front()
		for entry in ResourceLoader.list_directory(element):
			if !entry.is_valid_filename():
				queue.push_back(element + entry)
			else:
				var res: Resource = load(element + entry)
				if res is Placeable:
					_lookup[res.id] = res


func get_placeable_name(id: String) -> String:
	if id == "key":
		return "a Key"

	if _lookup[id] is Ability:
		return "the " + _lookup[id].name

	return "a " + _lookup[id].name
