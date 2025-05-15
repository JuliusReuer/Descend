@tool
extends Window

@onready var gitub_to_itchio: ShowCheckbox = get_node("%Github to ItchIo Enabled")
@onready var itch_username: LineEdit = get_node("%Username")
@onready var itch_project_name: LineEdit = get_node("%ProjectName")
@onready var discord: ShowCheckbox = get_node("%Discord Enabled")
@onready var lint_enabled: ShowCheckbox = get_node("%Lint Checking Enabled")
@onready var lint_folder: PickFolderButton = get_node("%Lint Pick Folder")
@onready var format_enabled: ShowCheckbox = get_node("%Format Checking Enabled")
@onready var format_folder: PickFolderButton = get_node("%Format Pick Folder")


func _ready():
	close_requested.connect(hide)

	gitub_to_itchio.button_pressed = ProjectSettings.get_setting(
		WorkflowSettingsManager.GITHUB_TO_ITCH_ENABLED, false
	)
	gitub_to_itchio.update()
	itch_username.text = ProjectSettings.get_setting(
		WorkflowSettingsManager.GITHUB_TO_ITCH_USER, ""
	)
	itch_project_name.text = ProjectSettings.get_setting(
		WorkflowSettingsManager.GITHUB_TO_ITCH_PROJECT, ""
	)

	discord.button_pressed = ProjectSettings.get_setting(
		WorkflowSettingsManager.DISCORD_ENABLED, false
	)
	discord.update()
	lint_enabled.button_pressed = ProjectSettings.get_setting(
		WorkflowSettingsManager.LINT_CHECK_ENABLED, false
	)
	lint_enabled.update()
	lint_folder.set_path(ProjectSettings.get_setting(WorkflowSettingsManager.LINT_CHECK_FOLDER))

	format_enabled.button_pressed = ProjectSettings.get_setting(
		WorkflowSettingsManager.FORMAT_CHECK_ENABLED, false
	)
	format_enabled.update()
	format_folder.set_path(ProjectSettings.get_setting(WorkflowSettingsManager.FORMAT_CHECK_FOLDER))

	gitub_to_itchio.toggled.connect(_on_github_to_itch_io_enabled_toggled)
	itch_username.text_changed.connect(_on_username_text_changed)
	itch_project_name.text_changed.connect(_on_project_name_text_changed)

	discord.toggled.connect(_on_discord_enabled_toggled)

	lint_enabled.toggled.connect(_on_lint_checking_enabled_toggled)
	lint_folder.update.connect(_update_lint_folder)

	format_enabled.toggled.connect(_on_format_checking_enabled_toggled)
	format_folder.update.connect(_update_format_folder)


func _on_meta_clicked(meta):
	OS.shell_open(meta)


func _on_github_to_itch_io_enabled_toggled(toggled_on: bool) -> void:
	ProjectSettings.set_setting(WorkflowSettingsManager.GITHUB_TO_ITCH_ENABLED, toggled_on)
	ProjectSettings.save()


func _on_username_text_changed(new_text):
	ProjectSettings.set_setting(WorkflowSettingsManager.GITHUB_TO_ITCH_USER, new_text)
	ProjectSettings.save()


func _on_project_name_text_changed(new_text):
	ProjectSettings.set_setting(WorkflowSettingsManager.GITHUB_TO_ITCH_PROJECT, new_text)
	ProjectSettings.save()


func _on_discord_enabled_toggled(toggled_on: bool) -> void:
	ProjectSettings.set_setting(WorkflowSettingsManager.DISCORD_ENABLED, toggled_on)
	ProjectSettings.save()


func _on_lint_checking_enabled_toggled(toggled_on: bool) -> void:
	ProjectSettings.set_setting(WorkflowSettingsManager.LINT_CHECK_ENABLED, toggled_on)
	ProjectSettings.save()


func _update_lint_folder(path: String):
	ProjectSettings.set_setting(WorkflowSettingsManager.LINT_CHECK_FOLDER, path)
	ProjectSettings.save()


func _on_format_checking_enabled_toggled(toggled_on: bool) -> void:
	ProjectSettings.set_setting(WorkflowSettingsManager.FORMAT_CHECK_ENABLED, toggled_on)
	ProjectSettings.save()


func _update_format_folder(path: String):
	ProjectSettings.set_setting(WorkflowSettingsManager.FORMAT_CHECK_FOLDER, path)
	ProjectSettings.save()
