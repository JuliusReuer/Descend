class_name LintWorkflowTemplate
extends WorkflowTemplate


func get_export_specific_data() -> Dictionary[String,String]:
	var res: Dictionary[String,String] = super()
	var additional_data: Dictionary[String,String] = {
		LINT_FOLDER =
		ProjectSettings.get_setting(WorkflowSettingsManager.LINT_CHECK_FOLDER).replace(
			"res://", "./"
		)
	}
	res.merge(additional_data)
	return res
