extends Control

const ITEM_SLOT_PREFAB : PackedScene = preload("res://scenes/menu/item_slot.tscn")

export(NodePath) var slot_parent_path : NodePath

onready var _slot_parent = get_node(slot_parent_path) as Control

func _ready() -> void:
	refresh()


func get_slot_count() -> int:
	return GameManager.data.inventory.slots.size()


func refresh() -> void:
	_refill()


func _refill() -> void:
	NodeUtil.queue_free_children(_slot_parent)
	for i in range(get_slot_count()):
		var item_slot = ITEM_SLOT_PREFAB.instance()
		item_slot.slot_index = i
		_slot_parent.add_child(item_slot)

