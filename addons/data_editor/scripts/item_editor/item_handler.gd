tool
extends ValueHandler

export(NodePath) var name_edit_path : NodePath
export(NodePath) var price_spin_path : NodePath
export(NodePath) var texture_select_path : NodePath

onready var _name_edit = get_node(name_edit_path) as LineEdit
onready var _price_spin = get_node(price_spin_path) as SpinBox
onready var _texture_select = get_node(texture_select_path) as TextureSelect

func _ready_connections() -> void:
	_name_edit.connect("text_changed", self, "_on_value_property_changed",
			["name"])
	_price_spin.connect("value_changed", self, "_on_value_property_changed",
			["price"])
	_texture_select.connect("texture_selected", self, "_on_value_property_changed",
			["icon"])


func _refresh_controls_enabled() -> void:
	_refresh_control_enabled(_name_edit, "editable")
	_refresh_control_enabled(_price_spin, "editable")
	_refresh_control_enabled(_texture_select, "disabled", true)


func _refresh_control_values() -> void:
	_refresh_control_value(_name_edit, "text", "name", "")
	_refresh_control_value(_price_spin, "value", "price", 0)
	_set_node_value(_texture_select, "all", DataManager.list_icon_paths())
	_refresh_control_value(_texture_select, "texture", "icon")
