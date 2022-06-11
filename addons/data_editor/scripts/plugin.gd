tool
extends EditorPlugin

const MAIN_EDITOR_PREFAB : PackedScene = preload("res://addons/data_editor/scenes/editors/main_editor.tscn")
var _main_editor : Control

func _enter_tree() -> void:
	_main_editor = MAIN_EDITOR_PREFAB.instance()
	get_editor_interface().get_editor_viewport().add_child(_main_editor)
	make_visible(false)


func _exit_tree():
	if _main_editor != null and is_instance_valid(_main_editor):
		get_editor_interface().get_editor_viewport().remove_child(_main_editor)
		_main_editor.queue_free()


func save_external_data():
	DataManager.save_data()


func has_main_screen() -> bool:
	return true;


func make_visible(visible:bool) -> void:
	if _main_editor:
		_main_editor.visible = visible


func get_plugin_name() -> String:
	return "Data Editor"


func get_plugin_icon() -> Texture:
	return get_editor_interface().get_base_control().get_icon(
			"MaterialPreviewCube", "EditorIcons")
