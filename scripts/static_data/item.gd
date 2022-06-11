tool
extends IDValue

const NAME_PROPERTY = "Name"
const PRICE_PROPERTY = "Price"
const ICON_PROPERTY = "Icon"

var name : String
var price : int
var icon : Texture


func load_save_data(save_data:Dictionary) -> void:
	.load_save_data(save_data)
	name = save_data[NAME_PROPERTY]
	price = save_data[PRICE_PROPERTY]
	icon = load_variant(save_data[ICON_PROPERTY])


func to_save_data() -> Dictionary:
	var save_data : Dictionary = .to_save_data()
	save_data[NAME_PROPERTY] = name
	save_data[PRICE_PROPERTY] = price
	save_data[ICON_PROPERTY] = variant_to_save_data(icon)
	return save_data
