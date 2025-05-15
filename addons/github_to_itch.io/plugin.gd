@tool
extends EditorPlugin

const WelcomePopup = preload("res://addons/github_to_itch.io/plugin_files/popups/welcome.tscn")
const ConfigPopup = preload("res://addons/github_to_itch.io/plugin_files/popups/config.tscn")

var base_workflow: WorkflowTemplate
var discord_workflow: WorkflowTemplate
var linting_check_workflow: WorkflowTemplate
var format_check_workflow: WorkflowTemplate

var config_popup: Window = ConfigPopup.instantiate()
var welcome_popup: Window = WelcomePopup.instantiate()
var last_exports_modified_time: int
var last_project_modified_time: int


func create_workflow_templates():
	var base_template = "res://addons/github_to_itch.io/tempaltes/workflow_template.yml"
	var base_export = "res://.github/workflows/github_to_itch.yml"
	base_workflow = ItchIoWorkflowTemplate.new(base_template, base_export)

	var discord_notification_template = "res://addons/github_to_itch.io/tempaltes/notify_job.yml"
	var discord_notification_export = "res://.github/workflows/github_to_itch.yml"
	discord_workflow = ItchIoWorkflowTemplate.new(
		discord_notification_template, discord_notification_export
	)

	var linting_check_template = "res://addons/github_to_itch.io/tempaltes/check_lint.yml"
	var linting_check_export = "res://.github/workflows/check_lint.yml"
	linting_check_workflow = LintWorkflowTemplate.new(linting_check_template, linting_check_export)

	var format_check_template = "res://addons/github_to_itch.io/tempaltes/check_format.yml"
	var format_check_export = "res://.github/workflows/check_format.yml"
	format_check_workflow = FormatWorkflowTemplate.new(format_check_template, format_check_export)


func save(forced = false):
	var export_modified_time = FileAccess.get_modified_time("res://export_presets.cfg")
	var project_modified_time = FileAccess.get_modified_time("res://project.godot")

	if (
		forced
		or export_modified_time != last_exports_modified_time
		or project_modified_time != last_project_modified_time
	):
		last_exports_modified_time = export_modified_time
		last_project_modified_time = project_modified_time

		#Clear Workflow Folder
		var workflow_folder = DirAccess.open("res://.github/workflows")
		if workflow_folder:
			for file in workflow_folder.get_files():
				workflow_folder.remove(file)

		if ProjectSettings.get_setting(WorkflowSettingsManager.GITHUB_TO_ITCH_ENABLED, false):
			if ProjectSettings.get_setting(WorkflowSettingsManager.DISCORD_ENABLED, false):
				discord_workflow.save()
			else:
				base_workflow.save()
		if ProjectSettings.get_setting(WorkflowSettingsManager.LINT_CHECK_ENABLED):
			linting_check_workflow.save()
		if ProjectSettings.get_setting(WorkflowSettingsManager.FORMAT_CHECK_ENABLED):
			format_check_workflow.save()


func _enter_tree():
	create_workflow_templates()
	WorkflowSettingsManager.init()
	connect("project_settings_changed", func(): save(true))
	add_tool_menu_item("Github to itch.io Config", show_config_popup)

	if ProjectSettings.get_setting(WorkflowSettingsManager.SHOW_WELCOME):
		show_welcome_popup()
		ProjectSettings.set_setting(WorkflowSettingsManager.SHOW_WELCOME, false)


func _exit_tree():
	if config_popup.get_parent():
		config_popup.get_parent().remove_child(config_popup)
	if welcome_popup.get_parent():
		welcome_popup.get_parent().remove_child(welcome_popup)
	remove_tool_menu_item("Github to itch.io Config")


func show_config_popup():
	if not config_popup.get_parent():
		add_child(config_popup)
	config_popup.show()


func show_welcome_popup():
	if not welcome_popup.get_parent():
		add_child(welcome_popup)
	welcome_popup.show()
