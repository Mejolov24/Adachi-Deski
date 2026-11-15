@tool
class_name  FancySlider
extends HSlider

@export var Name: String = "":
	set(value):
		Name = value
		if has_node("name"):
			$name.text = value

@onready var name_label : Label = $name
@onready var value_label : Label = $value

func _ready() -> void:
	name_label.text = Name
	value_label.text = str(int(value))

func _on_value_changed(new_value: float) -> void:
	value_label.text = str(int(new_value))
