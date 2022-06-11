tool
extends ConfirmationDialog

signal id_confirmed(id)

export(NodePath) var id_edit_path

onready var _id_edit = get_node(id_edit_path) as LineEdit

var _id : String
var _id_validator : FuncRef
var _is_ready : bool = false

func _ready() -> void:
	_is_ready = true
	_id_edit.connect("text_changed", self, "_on_id_changed")
	get_ok().connect("pressed", self, "_on_ok_pressed")
	refresh()


func start(starting_id:String, id_validator:FuncRef) -> void:
	_id = starting_id
	_id_validator = id_validator
	refresh()


func refresh() -> void:
	if _is_ready:
		_refresh_id_edit()
		_refresh_ok_button()


func _refresh_id_edit() -> void:
	_id_edit.text = _id


func _refresh_ok_button() -> void:
	get_ok().disabled = not is_valid_id(_id)


func is_valid_id(id:String) -> bool:
	return _id_validator == null or _id_validator.call_func(id) == true


func _on_id_changed(id:String) -> void:
	_id = id
	_refresh_ok_button()


func _on_ok_pressed() -> void:
	emit_signal("id_confirmed", _id)
