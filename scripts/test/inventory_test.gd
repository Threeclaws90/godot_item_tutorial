extends Node

func _ready() -> void:
	fill_inventory_slot(0, "Weapons/Axe", 1)
	fill_inventory_slot(1, "Other/Potion", 10)
	fill_inventory_slot(2, "Other/Ring", 2)


func fill_inventory_slot(index:int, item_id:String, count:int) -> void:
	var slot : GameInventorySlot = GameManager.data.inventory.slots[index]
	slot.item_id = item_id
	slot.count = count
