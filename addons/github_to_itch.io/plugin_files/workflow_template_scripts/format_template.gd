class_name FormatWorkflowTemplate
extends WorkflowTemplate


func get_export_specific_data() -> Dictionary[String,String]:
	var res: Dictionary[String,String] = super()
	var additional_data: Dictionary[String,String] = {
		FORMAT_FOLDER =
		ProjectSettings.get_setting(WorkflowSettingsManager.FORMAT_CHECK_FOLDER).replace(
			"res://", "./"
		)
	}
	res.merge(additional_data)
	return res
