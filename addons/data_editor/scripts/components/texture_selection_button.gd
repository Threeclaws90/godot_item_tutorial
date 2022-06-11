tool
extends Control

signal texture_selected(texture)
signal texture_confirmed()

export(NodePath) var texture_rect_path
export(NodePath) var button_path
export(NodePath) var label_path

var texture_path setget set_texture_path, get_texture_path
var button_group setget set_button_group, get_button_group
var texture setget set_texture, get_texture
var texture_size setget set_texture_size, get_texture_size
var show_label setget set_label_shown, is_label_shown

var _texture_path : String
var _texture_size : Vector2 = Vector2.ZERO
var _show_label : bool
var _button_group : ButtonGroup
var _texture : Texture

onready var _texture_rect = get_node(texture_rect_path) as TextureRect
onready var _button = get_node(button_path) as BaseButton
onready var _label = get_node(label_path) as Label


func _ready() -> void:
	_button.connect("pressed", self, "_on_button_pressed")
	_button.connect("gui_input", self, "_on_button_gui_input")
	refresh()


func get_button_group() -> ButtonGroup:
	return _button_group


func set_button_group(value:ButtonGroup) -> void:
	_button_group = value
	refresh()


func get_texture() -> Texture:
	return _texture


func set_texture(value:Texture) -> void:
	_texture = value
	refresh()


func get_texture_path() -> String:
	return _texture_path


func set_texture_path(value:String) -> void:
	_texture_path = value


func get_texture_size() -> Vector2:
	return _texture_size


func set_texture_size(value:Vector2) -> void:
	_texture_size = value
	refresh()


func is_label_shown() -> bool:
	return _show_label


func set_label_shown(value:bool) -> void:
	_show_label = value
	refresh()


func select() -> void:
	if _button != null and is_instance_valid(_button):
		_button.grab_click_focus()
		_button.pressed = true


func refresh() -> void:
	if _texture_rect != null:
		_texture_rect.texture = _texture
		_texture_rect.rect_min_size = _texture_size
	if _button != null:
		_button.toggle_mode = true
		_button.group = _button_group
		_button.hint_tooltip = get_text()
	if _label != null:
		_label.visible = _show_label
		_label.text = get_text()


func get_text() -> String:
	if _texture == null and _texture_path.length() > 0:
		return _texture_path.get_file()
	elif _texture != null:
		return _texture.resource_path.get_file()
	else:
		return "None"


func needs_loading() -> bool:
	if _texture != null:
		return false
	if _texture_path.empty():
		return false
	if not ResourceLoader.exists(_texture_path):
		return false
	return true


func load_texture() -> void:
	if needs_loading():
		_texture = load(_texture_path) as Texture
		refresh()


func _on_button_pressed() -> void:
	if _texture == null and _texture_path.length() > 0:
		emit_signal("texture_selected", load(_texture_path))
	else:
		emit_signal("texture_selected", _texture)


func _on_button_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and not event.is_echo():
			if event.button_index == BUTTON_LEFT and event.doubleclick:
				accept_event()
				emit_signal("texture_confirmed")
