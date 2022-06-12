tool
extends DictionaryTree

export(NodePath) var item_handler_path : NodePath

onready var _item_handler = get_node(item_handler_path) as Control

func _ready() -> void:
	connect("selection_changed", self, "_on_item_selected")
	# Wait for the _ready function to be executed
	yield(get_tree(), "idle_frame")
	_dictionary = DataManager.get_items()
	refresh()

func _new_value(id:String) -> IDValue:
	var new_item : ItemData = ItemData.new()
	new_item.id = id
	new_item.name = id
	return new_item


func _duplicate_value(value:IDValue) -> IDValue:
	var copy = value.copy()
	return copy


func _on_item_selected(selected:TreeItem) -> void:
	if selected == null:
		_item_handler.value = null
	else:
		var meta = selected.get_metadata(0)
		if typeof(meta) == TYPE_DICTIONARY:
			_item_handler.value = null
		else:
			_item_handler.value = meta


func _on_visibility_changed() -> void:
	._on_visibility_changed()
	if get_dictionary() != DataManager.get_items():
		set_dictionary(DataManager.get_items())
