tool
extends Tree
class_name DictionaryTree

const DEFAULT_ID_INPUT_PREFAB : PackedScene = preload("res://addons/data_editor/scenes/components/id_input.tscn")

const ADD_VALUE = 10
const ADD_GROUP = 11
const DUPLICATE = 20
const DELETE = 40
const RENAME = 50

signal value_selected(value)
signal selection_changed(selected)

export(NodePath) var filter_edit_path : NodePath
export(bool) var can_duplicate : bool = false

var dictionary setget set_dictionary, get_dictionary

var _dictionary : Dictionary
var _collapsed_items : Array
var _selected : TreeItem
var _menu : PopupMenu

onready var _filter_edit = get_node(filter_edit_path) as LineEdit

func _ready() -> void:
	_menu = _create_context_menu()
	_filter_edit.connect("text_changed", self, "_on_filter_changed")
	connect("visibility_changed", self, "_on_visibility_changed")
	connect("item_double_clicked", self, "_on_item_double_clicked")
	connect("item_selected", self, "_on_tree_item_selected")
	connect("item_collapsed", self, "_on_item_collapsed")
	refresh()


func _gui_input(event:InputEvent) -> void:
	if event is InputEventKey:
		if not event.is_pressed() and not event.is_echo():
			match event.scancode:
				KEY_DELETE:
					delete_selected()
					accept_event()
				KEY_ESCAPE:
					deselect()
					accept_event()
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			_show_context_menu()
			accept_event()


func _create_context_menu() -> PopupMenu:
	var menu = PopupMenu.new()
	menu.add_item("Add Value", ADD_VALUE)
	menu.add_item("Add Group", ADD_GROUP)
	if can_duplicate:
		menu.add_item("Duplicate", DUPLICATE)
	menu.add_item("Delete Selected", DELETE)
	menu.add_item("Rename", RENAME)
	menu.connect("id_pressed", self, "_on_context_menu_pressed")
	add_child(menu)
	return menu


func _show_context_menu() -> void:
	select(get_item_at_position(get_local_mouse_position()))
	_menu.set_item_disabled(_menu.get_item_index(ADD_VALUE), not can_add())
	_menu.set_item_disabled(_menu.get_item_index(ADD_GROUP), not can_add())
	if can_duplicate:
		_menu.set_item_disabled(_menu.get_item_index(DUPLICATE), _selected == null)
	_menu.set_item_disabled(_menu.get_item_index(DELETE), _selected == null)
	_menu.set_item_disabled(_menu.get_item_index(RENAME), _selected == null)
	_menu.rect_position = get_global_mouse_position()
	_menu.popup()


func get_dictionary() -> Dictionary:
	return _dictionary


func set_dictionary(value:Dictionary) -> void:
	_dictionary = value
	_collapsed_items = _get_all_paths()
	_rebuild()


func get_selected() -> TreeItem:
	return _selected


func _get_all_paths() -> Array:
	return _accumulate_paths("", _dictionary, [])


func _accumulate_paths(current_path:String, dic:Dictionary, paths:Array) -> Array:
	for key in dic:
		var value = dic[key]
		var new_path = current_path + "/" + key if current_path.length() > 0 else key
		if typeof(value) == TYPE_DICTIONARY:
			_accumulate_paths(new_path, value, paths)
		paths.append(new_path)
	return paths


func _get_all_expanded_paths() -> Array:
	if get_root() == null:
		return []
	return _accumulate_expanded_paths("", get_root())


func _accumulate_expanded_paths(current_path:String, item:TreeItem, paths:Array = []) -> Array:
	var child = item.get_children()
	while child != null:
		if child.collapsed:
			child = child.get_next()
			continue
		var current_name = child.get_text(0)
		var new_path = current_path + "/" + current_name if current_path.length() > 0 else current_name
		paths.append(new_path)
		var metadata = item.get_metadata(0)
		if typeof(metadata) == TYPE_DICTIONARY:
			_accumulate_expanded_paths(new_path, child, paths)
		child = child.get_next()
	return paths


func _get_item_path(item:TreeItem) -> String:
	if item == null:
		return ""
	var path = item.get_text(0)
	item = item.get_parent()
	while item != null and item != get_root():
		path = item.get_text(0) + "/" + path
		item = item.get_parent()
	return path


func get_selected_path() -> String:
	return _get_item_path(_selected)


func get_selected_parent_path() -> String:
	var path : String = get_selected_path()
	var index = path.find_last("/")
	if index == -1:
		return ""
	return get_selected_path().left(index + 1)


func select_path(path:String) -> void:
	var segments : Array = path.split("/")
	var current : TreeItem = get_root().get_children()
	var text = segments.pop_front()
	while true:
		while current != null and current.get_text(0) != text:
			current = current.get_next()
		if current == null:
			return
		elif segments.empty():
			_selected = current
			current.select(0)
			emit_signal("selection_changed", _selected)
			return
		else:
			current = current.get_children()
			text = segments.pop_front()


func select(item:TreeItem) -> void:
	if item == null:
		deselect()
	else:
		_selected = item
		_selected.select(0)
		emit_signal("selection_changed", _selected)


func deselect() -> void:
	var selected = get_selected()
	if selected:
		selected.deselect(get_selected_column())
		_selected = null


func refresh() -> void:
	_refresh_collapsed()
	_rebuild()


func _refresh_collapsed() -> void:
	_collapsed_items = ArrayUtil.except(_get_all_paths(), _get_all_expanded_paths())


func _rebuild() -> void:
	_selected = null
	clear()
	_create_dictionary_item(null, _dictionary, "")
	emit_signal("selection_changed", _selected)


func delete_selected() -> void:
	if _selected == get_root():
		_dictionary.clear()
		_delete_path("")
		refresh()
	elif _selected != null:
		var dictionary : Dictionary = _selected.get_parent().get_metadata(0)
		_delete_path(get_selected_path())
		dictionary.erase(_selected.get_text(0))
		refresh()


func _delete_path(path:String) -> void:
	pass


func _create_dictionary_item(parent:TreeItem, dictionary:Dictionary,
		name:String) -> TreeItem:
	var item : TreeItem = _create_value_item(parent, dictionary, name)
	var path = _get_item_path(item)
	var keys : Array = dictionary.keys()
	keys.sort()
	for key in keys:
		var value = dictionary[key]
		var sub_path = path.plus_file(key)
		if typeof(value) == TYPE_DICTIONARY and _is_dictionary_filtered(sub_path, value):
			_create_dictionary_item(item, value, key)
	for key in keys:
		var value = dictionary[key]
		var sub_path = path.plus_file(key)
		if typeof(value) != TYPE_DICTIONARY and _is_path_filtered(sub_path):
			_create_value_item(item, value, key)
	item.collapsed = ((item != get_root()) and (_collapsed_items.has(path)))
	return item


func _create_value_item(parent:TreeItem, value, name:String) -> TreeItem:
	var item : TreeItem = create_item(parent)
	item.set_text(0, name)
	item.set_metadata(0, value)
	return item


func _is_dictionary_filtered(path:String, dictionary:Dictionary) -> bool:
	if _is_path_filtered(path):
		return true
	for key in dictionary:
		var sub_path : String = path.plus_file(key)
		var value = dictionary[key]
		if typeof(value) == TYPE_DICTIONARY:
			if _is_dictionary_filtered(sub_path, value):
				return true
		elif _is_path_filtered(sub_path):
			return true
	return false


func _is_path_filtered(path:String) -> bool:
	if path.empty():
		return true
	var filter_string : String = _filter_edit.text.to_lower()
	return filter_string.empty() or (filter_string in path.to_lower())


func can_add() -> bool:
	return _selected == null or _selected.get_metadata(0) is Dictionary


func _add_value(id:String) -> void:
	var parent = get_root() if _selected == null else _selected
	var new_value : IDValue = _new_value(id)
	_insert_value(new_value, id, parent)


func _new_value(id:String) -> IDValue:
	return null


func _add_group(key:String) -> void:
	var parent = get_root() if _selected == null else _selected
	_insert_value({}, key, parent)


func _rename_selected(key:String) -> void:
	var old_key = _selected.get_text(0)
	var old_paths : Array = get_leaf_paths(_selected)
	var value = _selected.get_metadata(0)
	_rename_value(old_key, key, value)
	var dictionary : Dictionary = _selected.get_parent().get_metadata(0)
	_selected.set_text(0, key)
	var new_paths : Array = get_leaf_paths(_selected)
	for i in range(0, old_paths.size()):
		_swap_paths(old_paths[i], new_paths[i])
		_move_path(old_paths[i], new_paths[i])
	dictionary[key] = value
	dictionary.erase(old_key)
	emit_signal("selection_changed", _selected)


func _rename_value(old_name:String, new_name:String, value) -> void:
	pass


func _insert_value(value, key:String, parent:TreeItem = null) -> TreeItem:
	var dictionary : Dictionary = parent.get_metadata(0) if \
			parent != null else _dictionary
	dictionary[key] = value
	if value is Dictionary:
		return _create_dictionary_item(parent, value, key)
	else:
		return _create_value_item(parent, value, key)


func show_add_value_popup() -> void:
	var popup = DEFAULT_ID_INPUT_PREFAB.instance()
	popup.window_title = "New Value..."
	popup.start("ID", funcref(self, "_is_valid_key"))
	popup.connect("id_confirmed", self, "_add_value")
	add_child(popup)
	popup.popup_centered()


func show_add_group_popup() -> void:
	var popup = DEFAULT_ID_INPUT_PREFAB.instance()
	popup.window_title = "New Group..."
	popup.start("Group", funcref(self, "_is_valid_key"))
	popup.connect("id_confirmed", self, "_on_group_added")
	add_child(popup)
	popup.popup_centered()


func show_rename_popup() -> void:
	var popup = DEFAULT_ID_INPUT_PREFAB.instance()
	popup.window_title = "Rename..."
	popup.start(_selected.get_text(0), funcref(self, "_is_valid_key"))
	popup.connect("id_confirmed", self, "_on_value_renamed")
	add_child(popup)
	popup.popup_centered()


func duplicate_selected() -> void:
	var selected : TreeItem = _selected
	if selected == null:
		return
	var parent : TreeItem = _selected.get_parent()
	if parent == null:
		return
	var metadata = selected.get_metadata(0)
	var copy = _duplicate_group(metadata) if typeof(metadata) == TYPE_DICTIONARY else \
			_duplicate_value(metadata)
	var new_key : String = _get_valid_key(copy.id)
	_insert_value(copy, new_key, parent)


func _duplicate_group(group:Dictionary) -> Dictionary:
	var copy : Dictionary = {}
	for key in group:
		var value = group[key]
		if typeof(value) == TYPE_DICTIONARY:
			group[key] = _duplicate_group(value)
		elif value is IDValue:
			group[key] = _duplicate_value(value)
	return copy


func _duplicate_value(value:IDValue) -> IDValue:
	return null


func _is_valid_key(key:String) -> bool:
	var dictionary : Dictionary = _dictionary
	if _selected != null:
		var metadata = _selected.get_metadata(0)
		if typeof(metadata) != TYPE_DICTIONARY:
			dictionary = _selected.get_parent().get_metadata(0)
		else:
			dictionary = metadata
	return key.length() > 0 and not dictionary.has(key) and not "/" in key


func _get_valid_key(key:String) -> String:
	var regex : RegEx = RegEx.new()
	regex.compile("^.*(\\(\\d+\\))$")
	var mtch : RegExMatch = regex.search(key)
	var base_string : String = key
	if mtch != null:
		var start_index : int = base_string.length() - mtch.strings[1].length()
		base_string = base_string.substr(start_index)
	print(base_string)
	base_string = base_string.strip_edges()
	var new_key : String = base_string
	var index = 0
	while not _is_valid_key(new_key):
		index += 1
		new_key = base_string + ("(%d)" % [index])
	return new_key


func get_drag_data(position:Vector2):
	var item : TreeItem = get_item_at_position(position)
	if item == null:
		return null
	return {
		"type": "tree_item",
		"tree": self,
		"item": item,
	}


func can_drop_data(position:Vector2, data) -> bool:
	var item : TreeItem = get_item_at_position(position)
	if item != null and not item.get_metadata(0) is Dictionary:
		return false
	if data is Dictionary and data.get("type") == "tree_item" and \
			data.get("tree") == self:
		var dragged_item : TreeItem = data.get("item")
		if item != dragged_item:
			drop_mode_flags = DROP_MODE_ON_ITEM
			return true
	return false


func drop_data(position:Vector2, data) -> void:
	var item : TreeItem = get_item_at_position(position)
	var dropped : TreeItem = data.get("item")
	var old_paths : Array = get_leaf_paths(dropped)
	dropped.get_parent().get_metadata(0).erase(dropped.get_text(0))
	var new_item = _insert_value(dropped.get_metadata(0), dropped.get_text(0), item)
	var new_paths : Array = get_leaf_paths(new_item)
	for i in range(0, min(old_paths.size(), new_paths.size())):
		_swap_paths(old_paths[i], new_paths[i])
		_move_path(old_paths[i], new_paths[i])
	if _selected == dropped:
		_selected = new_item
		new_item.select(0)
		emit_signal("selection_changed", _selected)
	drop_mode_flags = DROP_MODE_DISABLED
	refresh()


func get_absolute_path(item:TreeItem) -> String:
	var path = ""
	while item != null:
		if path.empty():
			path = item.get_text(0)
		else:
			path = item.get_text(0).plus_file(path)
		item = item.get_parent()
	return path


func get_leaf_paths(item:TreeItem) -> Array:
	var metadata = item.get_metadata(0)
	if typeof(metadata) == TYPE_DICTIONARY:
		var paths : Array = []
		var child : TreeItem = item.get_children()
		while child != null:
			var child_paths : Array = get_leaf_paths(child)
			paths.append_array(child_paths)
			child = child.get_next()
		return paths
	return [get_absolute_path(item)]


func _move_path(old_path:String, new_path:String) -> void:
	pass


func _swap_paths(old_path:String, new_path:String) -> void:
	pass


func _on_context_menu_pressed(id:int) -> void:
	match id:
		ADD_VALUE:
			show_add_value_popup()
		ADD_GROUP:
			show_add_group_popup()
		DUPLICATE:
			duplicate_selected()
		DELETE:
			delete_selected()
		RENAME:
			show_rename_popup()


func _on_item_double_clicked() -> void:
	var metadata = _selected.get_metadata(0)
	if not metadata is Dictionary:
		emit_signal("value_selected", metadata)


func _on_tree_item_selected() -> void:
	select(.get_selected())


func _on_group_added(key:String) -> void:
	_add_group(key)


func _on_value_renamed(key:String) -> void:
	_rename_selected(key)


func _on_item_collapsed(item:TreeItem) -> void:
	if item == get_root():
		return
	var path : String = _get_item_path(item)
	if item.collapsed:
		_collapsed_items.append(path)
	else:
		_collapsed_items.erase(path)


func _on_visibility_changed() -> void:
	if not visible:
		_refresh_collapsed()


func _on_filter_changed(text:String) -> void:
	refresh()
