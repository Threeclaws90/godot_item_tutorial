tool
extends AcceptDialog

const BUTTON_PREFAB : PackedScene = preload("res://addons/data_editor/scenes/components/texture/texture_selection_button.tscn")

signal texture_selected(texture)

export(NodePath) var filter_edit_path
export(NodePath) var size_parent_path
export(NodePath) var selection_parent_path

onready var _filter_edit = get_node(filter_edit_path) as LineEdit
onready var _size_parent = get_node(size_parent_path) as Control
onready var _selection_parent = get_node(selection_parent_path) as GridContainer

var texture_size setget set_texture_size, get_texture_size
var selected setget set_selected, get_selected
var all setget set_all, get_all
var show_labels : bool

var _texture_size : Vector2 = Vector2.ZERO
var _selected : Texture
var _all : Array
var _loading_thread : Thread = Thread.new()

func _ready() -> void:
	_filter_edit.connect("text_changed", self, "_on_filter_changed")
	connect("popup_hide", self, "queue_free")
	get_ok().connect("pressed", self, "_on_ok")
	refresh()


func get_texture_size() -> Vector2:
	return _texture_size


func set_texture_size(value:Vector2) -> void:
	_texture_size = value


func get_selected() -> Texture:
	return _selected


func set_selected(value:Texture) -> void:
	_selected = value
	if _selection_parent:
		for button in _selection_parent.get_children():
			if button.texture == _selected:
				button.select()


func get_all() -> Array:
	return _all


func set_all(value:Array) -> void:
	_all = value
	refresh()


func refresh() -> void:
	if _loading_thread.is_active():
		_loading_thread.wait_to_finish()
	_fill()
	_start_loading_thread()


func _fill() -> void:
	if _selection_parent == null:
		return
	NodeUtil.free_children(_selection_parent)
	var group = ButtonGroup.new()
	var selected = null
	for element in ([null] + _all):
		var button = BUTTON_PREFAB.instance()
		button.size_flags_horizontal = 0
		button.size_flags_vertical = 0
		if typeof(element) == TYPE_STRING:
			button.texture_path = element
		elif typeof(element) == TYPE_OBJECT:
			button.texture = element as Texture
		button.button_group = group
		button.show_label = show_labels
		button.texture_size = _texture_size
		button.connect("texture_selected", self, "_on_texture_selected")
		button.connect("texture_confirmed", self, "_on_texture_confirmed")
		_selection_parent.add_child(button)
		if typeof(element) == TYPE_STRING:
			if element.empty() and _selected == null:
				selected = button
			elif _selected != null and element == _selected.resource_path:
				selected = button
		elif element == _selected:
			selected = button
	if selected == null:
		selected = _selection_parent.get_child(0)
	if selected.needs_loading():
		selected.load_texture()
	yield(get_tree(), "idle_frame")
	var parent_width : int = _size_parent.rect_size.x
	var texture_width : int = _texture_size.x
	var spacing : int = 4
	_selection_parent.columns = max(1, floor(parent_width / (texture_width + spacing)))
	selected.select()


func _get_buttons_to_load() -> Array:
	if _selection_parent == null:
		return []
	var buttons : Array = []
	for child in _selection_parent.get_children():
		if child.needs_loading():
			buttons.append(child)
	buttons.invert()
	return buttons


func _start_loading_thread() -> void:
	var to_load : Array = _get_buttons_to_load()
	if to_load.size() > 0:
		_loading_thread.start(self, "_load_button_textures", to_load)


func _load_button_textures(buttons:Array) -> void:
	while buttons.size() > 0:
		var button = buttons.pop_back()
		button.load_texture()
	_loading_thread.call_deferred("wait_to_finish")


func _on_ok() -> void:
	emit_signal("texture_selected", _selected)
	queue_free()


func _on_texture_confirmed() -> void:
	emit_signal("texture_selected", _selected)
	queue_free()


func _on_texture_selected(texture:Texture) -> void:
	_selected = texture


func _on_filter_changed(filter:String) -> void:
	filter = filter.to_lower()
	for button in _selection_parent.get_children():
		var texture : Texture = button.texture
		if texture == null:
			button.visible = true
		else:
			var resource_path : String = texture.resource_path.get_file().get_basename().to_lower()
			button.visible = (filter in resource_path) or filter.empty()
