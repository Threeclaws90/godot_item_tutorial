tool
extends Reference
class_name Saveable

const SAVEABLE_TYPE_PROPERTY = "Saveable Type"
const RESOURCE_PATH_PROPERTY = "Resource Path"
const SAVE_DATA_PROPERTY = "Save Data"
const SCRIPT_PROPERTY = "Script"
const X_PROPERTY = "X"
const Y_PROPERTY = "Y"
const Z_PROPERTY = "Z"
const R_PROPERTY = "R"
const G_PROPERTY = "G"
const B_PROPERTY = "B"
const A_PROPERTY = "A"

const ARRAY_TYPE = "Array"
const DICTIONARY_TYPE = "Dictionary"
const SAVEABLE_TYPE = "Saveable"
const RESOURCE_TYPE = "Resource"
const VEC_2_TYPE = "Vector 2"
const VEC_3_TYPE = "Vector 3"
const COLOR_TYPE = "Color"

static func variant_to_save_data(variant):
	match typeof(variant):
		TYPE_BOOL, TYPE_INT, TYPE_REAL, TYPE_STRING:
			return variant
		TYPE_ARRAY:
			return array_to_save_data(variant)
		TYPE_DICTIONARY:
			return dictionary_to_save_data(variant)
		TYPE_OBJECT:
			return object_to_save_data(variant)
		TYPE_VECTOR2:
			return vec2_to_save_data(variant)
		TYPE_VECTOR3:
			return vec3_to_save_data(variant)
		TYPE_COLOR:
			return color_to_save_data(variant)
	return null


static func array_to_save_data(array:Array) -> Array:
	var save_data = {
		SAVEABLE_TYPE_PROPERTY: ARRAY_TYPE,
	}
	var save_data_array = []
	save_data_array.resize(array.size())
	var index = 0
	while index < array.size():
		save_data_array[index] = variant_to_save_data(array[index])
		index += 1
	save_data[SAVE_DATA_PROPERTY] = save_data_array
	return save_data


static func dictionary_to_save_data(dictionary:Dictionary) -> Dictionary:
	var save_data = {
		SAVEABLE_TYPE_PROPERTY: DICTIONARY_TYPE,
	}
	var save_data_dic = {}
	for key in dictionary:
		save_data_dic[key] = variant_to_save_data(dictionary[key])
	save_data[SAVE_DATA_PROPERTY] = save_data_dic
	return save_data


static func object_to_save_data(object:Object):
	if object != null:
		if object.has_method("to_save_data"):
			return {
				SAVEABLE_TYPE_PROPERTY: SAVEABLE_TYPE,
				RESOURCE_PATH_PROPERTY: object.get_script().resource_path,
				SAVE_DATA_PROPERTY: object.to_save_data()
			}
		elif object is Resource:
			return {
				SAVEABLE_TYPE_PROPERTY: RESOURCE_TYPE,
				RESOURCE_PATH_PROPERTY: object.resource_path
			}
	return null


static func vec2_to_save_data(vec2:Vector2) -> Dictionary:
	return {
		SAVEABLE_TYPE_PROPERTY: VEC_2_TYPE,
		X_PROPERTY: vec2.x,
		Y_PROPERTY: vec2.y,
	}


static func vec3_to_save_data(vec3:Vector3) -> Dictionary:
	return {
		SAVEABLE_TYPE_PROPERTY: VEC_3_TYPE,
		X_PROPERTY: vec3.x,
		Y_PROPERTY: vec3.y,
		Z_PROPERTY: vec3.z,
	}


static func color_to_save_data(color:Color) -> Dictionary:
	return {
		SAVEABLE_TYPE_PROPERTY: COLOR_TYPE,
		R_PROPERTY: color.r,
		G_PROPERTY: color.g,
		B_PROPERTY: color.b,
		A_PROPERTY: color.a,
	}


static func write_saveable_to_file(path:String, saveable):
	var file = File.new()
	var error = file.open(path, File.WRITE)
	if error == OK:
		var save_data = variant_to_save_data(saveable)
		var json : String = JSON.print(save_data)
		file.store_string(json)
	else:
		push_error("Could not open file: %s" % [path])
	file.close()


static func load_variant(save_data, object_creator:FuncRef = null):
	match typeof(save_data):
		TYPE_BOOL, TYPE_INT, TYPE_REAL, TYPE_STRING, TYPE_VECTOR2, TYPE_VECTOR3, \
		TYPE_COLOR, TYPE_OBJECT, TYPE_ARRAY:
			return save_data
		TYPE_DICTIONARY:
			match save_data.get(SAVEABLE_TYPE_PROPERTY):
				ARRAY_TYPE:
					return load_array(save_data[SAVE_DATA_PROPERTY], object_creator)
				DICTIONARY_TYPE:
					return load_dictionary(save_data[SAVE_DATA_PROPERTY], object_creator)
				SAVEABLE_TYPE:
					if object_creator != null:
						return object_creator.call_func(save_data[SAVE_DATA_PROPERTY])
					elif save_data.has(RESOURCE_PATH_PROPERTY):
						var path : String = save_data[RESOURCE_PATH_PROPERTY]
						if not ResourceLoader.exists(path):
							return null
						var script : GDScript = load(path) as GDScript
						if script == null:
							return null
						var saveable : Saveable = script.new() as Saveable
						if saveable == null:
							return null
						if save_data.has(SAVE_DATA_PROPERTY):
							var saveable_object_data : Dictionary = save_data[SAVE_DATA_PROPERTY]
							saveable.load_save_data(saveable_object_data)
						return saveable
					return null if object_creator == null else \
							object_creator.call_func(save_data[SAVE_DATA_PROPERTY])
				RESOURCE_TYPE:
					return load_external_resource(save_data[RESOURCE_PATH_PROPERTY])
				VEC_2_TYPE:
					return load_vec2(save_data)
				VEC_3_TYPE:
					return load_vec3(save_data)
				COLOR_TYPE:
					return load_color(save_data)
				_:
					return save_data
	return null


static func load_array(array:Array, object_creator:FuncRef) -> Array:
	var result = []
	var index = 0
	result.resize(array.size())
	while index < array.size():
		var element_save_data = array[index]
		var element = load_variant(element_save_data, object_creator)
		result[index] = element
		index += 1
	return result


static func load_dictionary(dictionary:Dictionary, object_creator:FuncRef) -> Dictionary:
	var result = {}
	for key in dictionary:
		result[key] = load_variant(dictionary[key], object_creator)
	return result


static func load_external_resource(resource_path) -> Resource:
	if typeof(resource_path) != TYPE_STRING:
		return null
	if ResourceLoader.exists(resource_path):
		return ResourceLoader.load(resource_path)
	return null


static func load_vec2(save_data:Dictionary) -> Vector2:
	return Vector2(save_data.get(X_PROPERTY, 0), save_data.get(Y_PROPERTY, 0))


static func load_vec3(save_data:Dictionary) -> Vector3:
	return Vector3(
		save_data.get(X_PROPERTY, 0),
		save_data.get(Y_PROPERTY, 0),
		save_data.get(Z_PROPERTY, 0)
	)


static func load_color(save_data:Dictionary) -> Color:
	return Color(
		save_data.get(R_PROPERTY, 0),
		save_data.get(G_PROPERTY, 0),
		save_data.get(B_PROPERTY, 0),
		save_data.get(A_PROPERTY, 0)
	)


static func save_to_file(path:String, variant) -> bool:
	var save_data = variant_to_save_data(variant)
	var file : File = File.new()
	if file.open(path, File.WRITE) == OK:
		var json : String = JSON.print(save_data)
		file.store_string(json)
		file.close()
		return true
	file.close()
	return false


static func load_saveable_from_file(path:String, object_creator:FuncRef = null,
		default_value = null, show_error:bool = true):
	var file = File.new()
	var error = file.open(path, File.READ)
	if not file.file_exists(path):
		return default_value
	if error == OK:
		var string : String = file.get_as_text()
		var json_parse_result : JSONParseResult = JSON.parse(string)
		if json_parse_result.error == OK:
			file.close()
			var result = load_variant(json_parse_result.result, object_creator)
			if typeof(default_value) == TYPE_NIL:
				return result
			if typeof(default_value) == typeof(result):
				return result
			if show_error:
				push_error("Expected type: %d; Type is: %d" % [typeof(default_value), typeof(result)])
			return default_value
		if show_error:
			push_error("Could not read json string due to: %s" % [json_parse_result.error_string])
	file.close()
	if show_error:
		push_error("Could not open file: %s" % [path])
	return default_value

#warning-ignore:UNUSED_ARGUMENT
func load_save_data(save_data:Dictionary) -> void:
	pass


func to_save_data() -> Dictionary:
	return {}
