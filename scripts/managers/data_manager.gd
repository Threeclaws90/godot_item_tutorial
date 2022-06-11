tool
extends Node

const ITEM_FILE = "res://data/items.json"

const ICON_DIRECTORY = "res://graphics/icons/"

var _items : Dictionary

func _ready() -> void:
	_load_data()


func _load_data() -> void:
	_items = Saveable.load_saveable_from_file(ITEM_FILE, null, {})


func save_data() -> void:
	if not Saveable.save_to_file(ITEM_FILE, _items):
		printerr("Could not save items.")


func get_item(item_path:String) -> Reference:
	return _find_value(item_path, _items)


func get_items() -> Dictionary:
	return _items


func list_items() -> Array:
	return _accumulate_values(_items)


func list_item_paths() -> Array:
	return _accumulate_paths(_items)


func list_icon_paths() -> Array:
	return _get_directory_paths(ICON_DIRECTORY, ["jpg", "png"])


func _find_value(path:String, dictionary:Dictionary) -> Reference:
	var segments : Array = Array(path.split("/"))
	var value : Reference = null
	while segments.size() > 0:
		var segment : String = segments.pop_front()
		if segments.empty():
			value = dictionary.get(segment)
		else:
			dictionary = dictionary[segment]
	return value


func _accumulate_values(dictionary:Dictionary) -> Array:
	var values : Array = []
	for value in dictionary.values():
		if typeof(value) == TYPE_DICTIONARY:
			var sub_values : Array = _accumulate_values(value)
			values.append_array(sub_values)
		else:
			values.append(value)
	return values


func _accumulate_paths(dictionary:Dictionary, path:String = "") -> Array:
	var paths : Array = []
	for key in dictionary:
		var value = dictionary[key]
		var full_path : String = path.plus_file(key)
		if typeof(value) == TYPE_DICTIONARY:
			var sub_paths : Array = _accumulate_paths(value, full_path)
			paths.append_array(sub_paths)
		else:
			paths.append(full_path)
	return paths


func _get_directory_paths(directory_path:String, allowed_file_types:Array) -> Array:
	var directory : Directory = Directory.new()
	var paths : Array = []
	if directory.open(directory_path) == OK:
		if directory.list_dir_begin(true, true) == OK:
			while true:
				var file_name : String = directory.get_next()
				if file_name.empty():
					break
				var full_path = directory_path.plus_file(file_name)
				if directory.current_is_dir():
					var sub_paths = _get_directory_paths(full_path, allowed_file_types)
					paths.append_array(sub_paths)
				elif allowed_file_types.has(file_name.get_extension()):
					paths.append(full_path)
		directory.list_dir_end()
	else:
		push_warning("Could not open directory \"%s\"" % [directory_path])
	return paths
