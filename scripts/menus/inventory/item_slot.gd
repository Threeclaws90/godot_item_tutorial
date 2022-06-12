extends Control

const DRAG_DATA_TYPE_PROPERTY = "drag_data_type"
const SLOT_PROPERTY = "inventory_slot"
const INVENTORY_SLOT_TYPE = "inventory_slot"

export(NodePath) var button_path
export(NodePath) var icon_rect_path
export(NodePath) var count_label_path

onready var _button = get_node(button_path) as BaseButton
onready var _icon_rect = get_node(icon_rect_path) as TextureRect
onready var _count_label = get_node(count_label_path) as Label

var slot_index setget set_slot_index, get_slot_index

var _slot_index : int
var _is_ready : bool

func _ready() -> void:
	_is_ready = true
	# warning-ignore:return_value_discarded
	get_slot_data().connect("content_changed", self, "refresh")
	refresh()


func get_slot_index() -> int:
	return _slot_index


func set_slot_index(value:int) -> void:
	_slot_index = value
	refresh()


func get_slot_data() -> GameInventorySlot:
	return GameManager.data.inventory.slots[_slot_index]


func get_item_data() -> ItemData:
	return get_slot_data().get_item_data()


func refresh() -> void:
	if _is_ready:
		var item_data : ItemData = get_item_data()
		if item_data == null:
			_button.disabled = true
			_icon_rect.texture = null
			_count_label.text = ""
			hint_tooltip = ""
		else:
			_button.disabled = false
			_icon_rect.texture = item_data.icon
			_count_label.text = String(get_slot_data().count)
			hint_tooltip = item_data.name


# warning-ignore:unused_argument
func get_drag_data(position):
	if get_item_data() == null:
		return null
	set_drag_preview(_create_drag_preview())
	return {
		DRAG_DATA_TYPE_PROPERTY: INVENTORY_SLOT_TYPE,
		SLOT_PROPERTY: get_slot_data(),
	}


func _create_drag_preview() -> Control:
	var prefab : PackedScene = load(filename)
	var drag_preview = prefab.instance()
	drag_preview.slot_index = _slot_index
	return drag_preview


# warning-ignore:unused_argument
func can_drop_data(position:Vector2, data) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return data
	var dictionary : Dictionary = data
	if dictionary.get(DRAG_DATA_TYPE_PROPERTY) != INVENTORY_SLOT_TYPE:
		return false
	return true


# warning-ignore:unused_argument
func drop_data(position:Vector2, data) -> void:
	var dragged_slot : GameInventorySlot = data.get(SLOT_PROPERTY)
	var dropped_slot : GameInventorySlot = get_slot_data()
	dropped_slot.swap_with_slot(dragged_slot)
	grab_focus()
