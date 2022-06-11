tool
extends Control
class_name TextureSelect

const TEXTURE_SELECTION_PREFAB : PackedScene = preload("res://addons/data_editor/scenes/components/texture/texture_selection_popup.tscn")

signal texture_selected(texture)

export(Vector2) var texture_size = Vector2(128, 128)
export(bool) var disabled setget set_disabled, is_disabled

export(NodePath) var background_panel_path
export(NodePath) var texture_rect_path
export(NodePath) var button_path
export(bool) var show_labels

var all setget set_all, get_all
var texture setget set_texture, get_texture

var _all : Array
var _texture : Texture
var _disabled : bool = false

onready var _background_panel = get_node(background_panel_path) as Panel
onready var _texture_rect = get_node(texture_rect_path) as TextureRect
onready var _button = get_node(button_path) as BaseButton

func _ready() -> void:
	if _button.get_index() < get_child_count() - 1:
		move_child(_button, get_child_count())
	_button.connect("pressed", self, "_on_button_pressed")
	refresh()


func is_disabled() -> bool:
	return _disabled


func set_disabled(value:bool) -> void:
	_disabled = value
	refresh()


func get_all() -> Array:
	return _all


func set_all(value:Array) -> void:
	_all = value
	refresh()


func get_texture() -> Texture:
	return _texture


func set_texture(value:Texture) -> void:
	_texture = value
	refresh()


func get_current_style() -> StyleBox:
	if _disabled:
		return get_disabled_style()
	return get_normal_style()


func get_normal_style() -> StyleBox:
	return get_stylebox("normal", "LineEdit")


func get_disabled_style() -> StyleBox:
	return get_stylebox("read_only", "LineEdit")


func refresh() -> void:
	if _texture_rect:
		_texture_rect.texture = _texture
	if _background_panel:
		_background_panel.add_stylebox_override("panel", get_current_style())
	if _button:
		_button.disabled = _disabled


func _show_selection_popup() -> void:
	if _all.empty() or _disabled:
		return
	var prefab = TEXTURE_SELECTION_PREFAB.instance()
	prefab.show_labels = show_labels
	prefab.texture_size = texture_size
	prefab.connect("texture_selected", self, "_on_texture_selected")
	prefab.selected = _texture
	prefab.all = _all
	add_child(prefab)
	prefab.popup_centered()


func _on_button_pressed() -> void:
	_show_selection_popup()


func _on_texture_selected(texture:Texture) -> void:
	_texture = texture
	refresh()
	emit_signal("texture_selected", texture)
