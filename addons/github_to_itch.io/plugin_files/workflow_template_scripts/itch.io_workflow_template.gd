class_name ItchIoWorkflowTemplate
extends WorkflowTemplate

var ITCH_CHANNEL_MAP: Dictionary[String,String] = {
	"Web": "web",
	"HTML5": "web",
	"Windows Desktop": "win",
	"Android": "android",
	"iOS": "ios",
	"Linux/X11": "linux",
	"macOS": "mac",
	"UWP": "uwp"
}  # not an official channel of itch  # not an official channel of itch

var export_template: String = (
	"""  - name: Export {PLATFORM}
	run: |
	 mkdir -p ./{EXPORT_PATH}
	 ./godot --headless --path ./ --export-release "{NAME}" ./{EXPORT_FILE}

"""
	. replace("\t", "    ")
)
var uploads_template: String = (
	"""	- name: Push {PLATFORM} to Itch
	  run: ./butler push {EXPORT_PATH} {ITCH_USERNAME}/{ITCH_PROJECT_NAME}:{ITCH_CHANNEL} --userversion-file ./VERSION/VERSION.txt

"""
	. replace("\t", "    ")
)


func _generate_exports_string() -> String:
	var exports = GlobalTemplateData.get_exports()

	var res: PackedStringArray
	for export in exports:
		res.append(
			export_template.format(
				{
					NAME = export.name,
					PLATFORM = export.platform,
					EXPORT_PATH = export.export_path.get_base_dir(),
					EXPORT_FILE = export.export_path
				}
			)
		)

	return "".join(res)


func _generate_uploads_string():
	var exports = GlobalTemplateData.get_exports()
	var ITCH_USERNAME = ProjectSettings.get_setting(WorkflowSettingsManager.GITHUB_TO_ITCH_USER, "")
	var ITCH_PROJECT_NAME = ProjectSettings.get_setting(
		WorkflowSettingsManager.GITHUB_TO_ITCH_PROJECT, ""
	)

	var res: PackedStringArray
	for export in exports:
		res.append(
			uploads_template.format(
				{
					PLATFORM = export.platform,
					EXPORT_PATH = "./" + export.export_path.get_base_dir(),
					ITCH_CHANNEL = ITCH_CHANNEL_MAP[export.platform],
					ITCH_USERNAME = ITCH_USERNAME.to_lower(),
					ITCH_PROJECT_NAME = ITCH_PROJECT_NAME.to_lower()
				}
			)
		)

	return "".join(res)


func get_export_specific_data() -> Dictionary[String,String]:
	var res: Dictionary[String,String] = super()
	var additional_data: Dictionary[String,String] = {
		ITCH_PROJECT_NAME =
		ProjectSettings.get_setting(WorkflowSettingsManager.GITHUB_TO_ITCH_PROJECT, ""),
		ITCH_USERNAME =
		ProjectSettings.get_setting(WorkflowSettingsManager.GITHUB_TO_ITCH_USER, ""),
		EXPORTS_FROM_GODOT = _generate_exports_string(),
		UPLOADS_TO_ITCH = _generate_uploads_string()
	}
	res.merge(additional_data)
	return res
