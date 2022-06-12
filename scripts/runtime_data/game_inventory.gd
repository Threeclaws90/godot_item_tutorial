extends Savable
class_name GameInventory

const DEFAULT_SIZE = 36
const SLOTS_PROPERTY = "Slots"

var slots : Array

func _init():
	slots = []
	# warning-ignore:unused_variable
	for i in range(DEFAULT_SIZE):
		slots.append(GameInventorySlot.new())


func load_save_data(save_data:Dictionary) -> void:
	slots = save_data[SLOTS_PROPERTY]


func to_save_data() -> Dictionary:
	var save_data : Dictionary = .to_save_data()
	save_data[SLOTS_PROPERTY] = variant_to_save_data(slots)
	return save_data
