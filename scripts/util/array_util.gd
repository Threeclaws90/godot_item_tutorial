tool
extends Reference
class_name ArrayUtil

static func fill(array:Array, size:int, variant) -> Array:
	array.resize(size)
	var i = 0
	while i < size:
		array[i] = variant
		i += 1
	return array


static func reinsert(array:Array, old_index:int, new_index:int) -> void:
	var data = array[old_index]
	if old_index < new_index:
		array.insert(new_index, data)
		array.remove(old_index)
	elif old_index > new_index:
		array.remove(old_index)
		array.insert(new_index, data)


static func replace(array:Array, old_value, new_value) -> bool:
	var index = 0
	while index < array.size():
		if array[index] == old_value:
			array[index] = new_value
			return true
		index += 1
	return false


static func replace_all(array:Array, old_value, new_value) -> bool:
	if old_value == new_value:
		return false
	var changed : bool = false
	var index = 0
	while index < array.size():
		if array[index] == old_value:
			array[index] = new_value
			changed = true
		index += 1
	return changed


static func swap(array:Array, index1:int, index2:int) -> void:
	if index1 >= 0 and index1 < array.size() and index2 >= 0 and index2 < array.size():
		var temp = array[index1]
		array[index1] = array[index2]
		array[index2] = temp


static func move_up(array:Array, index:int) -> void:
	swap(array, index, index - 1)


static func move_down(array:Array, index:int) -> void:
	swap(array, index, index + 1)


static func reduce(array:Array, instance, func_name:String, start_value):
	var function = FuncRef.new()
	function.set_instance(instance)
	function.set_function(func_name)
	var result = start_value
	for element in array:
		result = function.call_func(result, element)
	return result


static func distinct(array:Array) -> Array:
	var new_array = []
	for element in array:
		if not new_array.has(element):
			new_array.append(element)
	return new_array


static func except(array:Array, to_remove:Array) -> Array:
	var new_array = []
	for element in array:
		if not to_remove.has(element):
			new_array.append(element)
	return new_array


static func intersect(array_1:Array, array_2:Array) -> Array:
	var new_array = []
	for element in array_1:
		if array_2.has(element):
			new_array.append(element)
	return new_array


static func filter(array:Array, instance, func_name:String, parameters:Array = []) -> Array:
	var predicate = FuncRef.new()
	predicate.set_instance(instance)
	predicate.set_function(func_name)
	var new_array = []
	for element in array:
		if predicate.call_funcv([element] + parameters) == true:
			new_array.append(element)
	return new_array


static func filter_by(array:Array, properties:Array, values:Array) -> Array:
	var new_array = []
	for element in array:
		var is_valid = true
		for i in range(properties.size()):
			var property = properties[i]
			if element.get(property) != values[i]:
				is_valid = false
				break
		if is_valid:
			new_array.append(element)
	return new_array


static func filter_null(array:Array) -> Array:
	var new_array = []
	for element in array:
		if element != null:
			new_array.append(element)
	return new_array


static func filter_points_left_of(points:Array, x:int) -> Array:
	var result : Array = []
	for point in points:
		if typeof(point) != TYPE_VECTOR2:
			continue
		if point.x < x:
			continue
		result.append(point)
	return result


static func filter_points_right_of(points:Array, x:int) -> Array:
	var result : Array = []
	for point in points:
		if typeof(point) != TYPE_VECTOR2:
			continue
		if point.x > x:
			continue
		result.append(point)
	return result


static func filter_points_below(points:Array, y:int) -> Array:
	var result : Array = []
	for point in points:
		if typeof(point) != TYPE_VECTOR2:
			continue
		if point.y < y:
			continue
		result.append(point)
	return result


static func filter_points_above(points:Array, y:int) -> Array:
	var result : Array = []
	for point in points:
		if typeof(point) != TYPE_VECTOR2:
			continue
		if point.y > y:
			continue
		result.append(point)
	return result


static func map(array:Array, instance, func_name:String, parameters:Array = []) -> Array:
	var map_func = funcref(instance, func_name)
	var new_array = []
	for element in array:
		new_array.append(map_func.call_funcv([element] + parameters))
	return new_array


static func first(array:Array, predicate:FuncRef, parameters:Array = []):
	for element in array:
		if predicate.call_funcv([element] + parameters):
			return element
	return null


static func find(array:Array, predicate:FuncRef, parameters:Array = []) -> int:
	for i in range(0, array.size()):
		var element = array[i]
		if predicate.call(element):
			return i
	return -1


static func find_by(array:Array, property:String, value) -> int:
	for i in range(0, array.size()):
		var element = array[i]
		if typeof(element) != TYPE_OBJECT and typeof(element) != TYPE_DICTIONARY:
			continue
		if element.get(property) == value:
			return i
	return -1


static func every(array:Array, predicate:FuncRef, parameters:Array) -> bool:
	for element in array:
		if not predicate.call_funcv([element] + parameters):
			return false
	return true


static func some(array:Array, predicate:FuncRef, parameters:Array) -> bool:
	for element in array:
		if predicate.call_funcv([element] + parameters):
			return true
	return false


static func remove_all(array: Array, to_remove:Array) -> void:
	for element in to_remove:
		for i in range(array.size() - 1, -1, -1):
			if element == array[i]:
				array.remove(i)


static func foreach(array:Array, function:FuncRef, parameters:Array) -> void:
	for element in array:
		function.call_funcv([element] + parameters)


static func generate_permutations(array:Array) -> Array:
	return _accumulate_permuations(array.size(), array.duplicate(), [])


static func _accumulate_permuations(k:int, array:Array, result:Array) -> Array:
	if k == 1:
		result.append(array.duplicate())
	else:
		_accumulate_permuations(k - 1, array, result)
		var index = 0
		var is_even : bool = k % 2 == 0
		while index < k -1:
			if is_even:
				swap(array, index, k -1)
			else:
				swap(array, 0, k-1)
			_accumulate_permuations(k - 1, array, result)
			index += 1
	return result
