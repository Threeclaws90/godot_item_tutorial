tool
extends Control
class_name ValueHandler

signal property_changed(property)

var value setget set_value, get_value

var _value

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	_ready_connections()
	refresh()


func _ready_connections() -> void:
	pass


func get_value():
	return _value


func set_value(value) -> void:
	var prev = _value
	_value = value
	if prev != value:
		refresh()


func is_enabled() -> bool:
	return _value != null


func refresh() -> void:
	_refresh_control_connections()
	_refresh_controls_visible()
	_refresh_controls_enabled()
	_refresh_control_values()


func _refresh_control_connections() -> void:
	pass


func _refresh_controls_visible() -> void:
	pass


func _refresh_controls_enabled() -> void:
	pass


func _refresh_control_values() -> void:
	pass


func _disonnect_objects(objects:Array) -> void:
	for object in objects:
		NodeUtil.disconnect_all(object)


func _refresh_control_connection(control:Control, signal_name:String,
		method_name:String) -> void:
	NodeUtil.disconnect_all(control)
	control.connect(signal_name, self, method_name)


func _refresh_control_visible(control:Control, visible:bool = _value != null) -> void:
	if control != null:
		control.visible = visible


func _refresh_control_enabled(control:Control, enabled_property:String,
		inverted:bool = false) -> void:
	if control != null:
		var value = (is_enabled() != inverted)
		control.set(enabled_property, value)


func _refresh_control_value(control:Control, control_property:String,
		value_property:String, default_value = null) -> void:
	if control != null:
		var value = _get_value_property(value_property, default_value)
		control.set(control_property, value)


func _get_value_property(property:String, default_value = null):
	if _value != null:
		if typeof(_value) == TYPE_DICTIONARY:
			return _value.get(property, default_value)
		elif typeof(_value) == TYPE_OBJECT:
			return _value.get(property)
	return default_value


func _set_value_property(property:String, value) -> void:
	if _value != null:
		if _value is Dictionary:
			_value[property] = value
			emit_signal("property_changed", property)
		elif _value is Object:
			_value.set(property, value)
			emit_signal("property_changed", property)


func _set_node_value(node:Node, property:String, value) -> void:
	if node != null and is_instance_valid(node):
		node.set(property, value)


func _on_value_property_changed(value, property:String) -> void:
	_set_value_property(property, value)


func _on_text_edit_text_changed(text_edit:TextEdit, property:String) -> void:
	_set_value_property(property, text_edit.text)


func _on_option_text_changed(index:int, option_button:OptionButton,
		property:String, include_none:bool = false) -> void:
	if include_none and index == 0:
		_set_value_property(property, "")
	else:
		_set_value_property(property, option_button.get_item_text(index))
