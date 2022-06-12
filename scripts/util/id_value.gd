tool
extends Savable
class_name IDValue

const ID_PROPERTY = "ID"

var id : String

func load_save_data(save_data:Dictionary) -> void:
	id = save_data[ID_PROPERTY]


func to_save_data() -> Dictionary:
	var save_data : Dictionary = .to_save_data()
	save_data[ID_PROPERTY] = id
	return save_data
