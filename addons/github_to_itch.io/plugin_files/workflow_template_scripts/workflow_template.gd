class_name WorkflowTemplate

var _template_path: String
var _export_path: String


func _init(template_path: String, export_path: String) -> void:
	_template_path = template_path
	_export_path = export_path


func save():
	var workflow_directory = _export_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(workflow_directory):
		DirAccess.make_dir_recursive_absolute(workflow_directory)

	var file = FileAccess.open(_export_path, FileAccess.WRITE)
	file.store_string(_generate_workflow_string())


func get_export_specific_data() -> Dictionary[String,String]:
	var version_info = GlobalTemplateData.get_version_info()
	var godot_path = version_info.version

	if version_info.status != "stable":
		godot_path += "/" + version_info.status

	return {
		PROJECT_NAME = GlobalTemplateData.get_project_name(),
		GODOT_VERSION = version_info.version,
		GODOT_STATUS = version_info.status,
		GODOT_PATH = godot_path,
	}


func get_yml_section_data(yml_string: String) -> Dictionary:
	var res = {}
	var lines = yml_string.split("\n")
	var last_begin = 0
	var begin_line = ""
	for line_id in len(lines):
		var line = lines[line_id]
		if line.is_empty():
			continue
		if line.begins_with(" ") or line.begins_with("\t") or line.begins_with("{"):
			continue
		if !begin_line.is_empty():
			res.set(begin_line, {"begin": last_begin, "end": line_id})
		last_begin = line_id
		begin_line = line
	res.set(begin_line, {"begin": last_begin, "end": len(lines)})
	return res


func generate_section(text: String, start: int, end: int):
	var lines = text.split("\n")
	var res = []
	for i in range(start, end):
		res.append(lines[i])
	return "\n".join(res)


func _extend(original: String, cwd: String) -> Dictionary[String,String]:
	var work_value = original.substr(8)
	var path = work_value.split("\n")[0].strip_edges()
	var file := FileAccess.open(cwd.path_join(path), FileAccess.READ)
	var file_template = file.get_as_text()

	var orginal_sections = get_yml_section_data(original)
	var template = get_yml_section_data(file_template)
	var orginal_text_sections: Dictionary[String,String] = {}
	for key in orginal_sections:
		if template.has(key):
			orginal_text_sections.set(
				key,
				generate_section(
					original, orginal_sections[key]["begin"] + 1, orginal_sections[key]["end"]
				)
			)

	var template_text_sections: Array[String] = []
	for key in template:
		var section = generate_section(file_template, template[key]["begin"], template[key]["end"])
		if orginal_text_sections.has(key):
			section += "\n" + orginal_text_sections[key]
		template_text_sections.append(section)

	return {
		"content": "\n\n".join(template_text_sections), "cwd": cwd.path_join(path).get_base_dir()
	}


func _generate_workflow_string() -> String:
	var file := FileAccess.open(_template_path, FileAccess.READ)
	var workflow_template = file.get_as_text()

	var cwd = _template_path.get_base_dir()
	while workflow_template.begins_with("#extends"):
		var obj = _extend(workflow_template, cwd)
		workflow_template = obj["content"]
		cwd = obj["cwd"]

	var specific_data: Dictionary = get_export_specific_data()
	return workflow_template.replace("\t", "    ").format(specific_data)
