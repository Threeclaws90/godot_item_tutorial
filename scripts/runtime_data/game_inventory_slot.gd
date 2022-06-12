extends Saveable
class_name GameInventorySlot

signal content_changed()

const ITEM_ID_PROPERTY = "Item ID"
const COUNT_PROPERTY = "Count"

var item_id setget set_item_id, get_item_id
var count setget set_count, get_count

var _item_id : String
var _count : int

func get_item_id() -> String:
	return _item_id


func set_item_id(value:String) -> void:
	_item_id = value
	emit_signal("content_changed")


func get_count() -> int:
	return _count


func set_count(value:int) -> void:
	_count = value
	emit_signal("content_changed")


func swap_with_slot(other_slot:Reference) -> void:
	var other_slot_item : String = other_slot._item_id
	var other_slot_count : int = other_slot._count
	other_slot._item_id = _item_id
	other_slot.count = _count
	_item_id = other_slot_item
	_count = other_slot_count
	emit_signal("content_changed")


func get_item_data() -> ItemData:
	return null if is_empty() else DataManager.get_item(_item_id)


func is_empty() -> bool:
	return _count <= 0 or DataManager.get_item(_item_id) == null


func load_save_data(save_data:Dictionary) -> void:
	_item_id = save_data[ITEM_ID_PROPERTY]
	_count = save_data[COUNT_PROPERTY]


func to_save_data() -> Dictionary:
	var save_data : Dictionary = .to_save_data()
	
	save_data[ITEM_ID_PROPERTY] = _item_id
	save_data[COUNT_PROPERTY] = _count
	
	return save_data
