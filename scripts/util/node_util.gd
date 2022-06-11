tool
extends Reference
class_name NodeUtil

static func disconnect_all(object:Object, signals:Array = []) -> void:
	if object == null:
		return
	if signals.empty():
		var signal_list = object.get_signal_list()
		for signal_data in signal_list:
			signals.append(signal_data["name"])
	for to_disconnect in signals:
		if not object.has_signal(to_disconnect):
			continue
		var connections = object.get_signal_connection_list(to_disconnect)
		for connection in connections:
			if not object.is_connected(to_disconnect,
					connection.target, connection.method):
				continue
			object.disconnect(to_disconnect,
					connection.target, connection.method)


static func set_visible(canvas_items:Array, value:bool) -> void:
	for item in canvas_items:
		var canvas_item : CanvasItem = item as CanvasItem
		if canvas_item != null:
			canvas_item.visible = value


static func hide_all(canvas_items:Array) -> void:
	for node in canvas_items:
		var canvas_item = node as CanvasItem
		if canvas_item != null:
			canvas_item.visible = false


static func show_all(canvas_items:Array) -> void:
	for node in canvas_items:
		var canvas_item = node as CanvasItem
		if canvas_item != null:
			canvas_item.visible = true


static func queue_free_children(node:Node) -> void:
	for child in node.get_children():
		if child != null and is_instance_valid(child):
			node.remove_child(child)
			child.queue_free()


static func free_children(node:Node) -> void:
	for child in node.get_children():
		if child != null and is_instance_valid(child):
			node.remove_child(child)
			child.free()


static func fill_options(option:OptionButton, values:Array,
		disable_on_empty:bool = true, empty_item:String = "") -> void:
	if option == null:
		return
	option.clear()
	if empty_item.length() > 0:
		option.add_item(empty_item)
	for value in values:
		option.add_item(String(value))
	if not option.disabled and option.get_item_count() <= 1 and disable_on_empty:
		option.disabled = true


static func select_option_text(option:OptionButton, text:String) -> void:
	if option == null or option.get_item_count() == 0:
		return
	for i in range(option.get_item_count()):
		if option.get_item_text(i) == text:
			option.selected = i
			return
	option.selected = 0


static func set_row_visible(grid:GridContainer, row:int, visible:bool) -> void:
	for i in range(row * grid.columns, row * grid.columns + grid.columns):
		grid.get_child(i).visible = visible


static func set_row_visible_by_child(grid:GridContainer, child:Node, visible:bool) -> void:
	if grid == null:
		return
	if child == null:
		return
	var index : int = child.get_index()
	if grid.get_child(index) == child:
		# warning-ignore:integer_division
		set_row_visible(grid, child.get_index() / grid.columns, visible)


static func set_rows_visible_by_children(grid:GridContainer, children:Array, visible:bool) -> void:
	for child in children:
		set_row_visible_by_child(grid, child, visible)


static func queue_free_child_at(parent:Node, index:int) -> void:
	if parent == null:
		return
	if index < 0 or index >= parent.get_child_count():
		return
	var child = parent.get_child(index)
	parent.remove_child(child)
	child.queue_free()


static func add_children(parent:Node, nodes:Array) -> void:
	for node in nodes:
		parent.add_child(node)


static func swap_children(parent:Node, index1:int, index2:int) -> void:
	var child1 = parent.get_child(index1)
	var child2 = parent.get_child(index2)
	parent.move_child(child1, index2)
	parent.move_child(child2, index1)
