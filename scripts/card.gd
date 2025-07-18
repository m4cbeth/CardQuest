extends Node2D
class_name Card
 
signal hovered
signal hovered_off

func _ready():
	get_parent().connect_card_signals(self)

func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)

var card_type = "door"
