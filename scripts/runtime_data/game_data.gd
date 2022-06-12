extends Savable
class_name GameData

const INVENTORY_PROPERTY : String = "Inventory"

var inventory : GameInventory

func _init() -> void:
	inventory = GameInventory.new()


func load_save_data(save_data:Dictionary) -> void:
	inventory = save_data[INVENTORY_PROPERTY]


func to_save_data() -> Dictionary:
	var save_data : Dictionary = .to_save_data()
	
	save_data[INVENTORY_PROPERTY] = inventory.to_save_data()
	
	return save_data
