class_name MoveableComponent
extends Node2D


@export var moveable_entity: Node2D

var is_dragging: bool = false


func _process(delta: float) -> void:
	if is_dragging:
		var mouse_pos: Vector2 = get_global_mouse_position()
		moveable_entity.global_position = mouse_pos

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("select"):
		is_dragging = true
	elif event.is_action_released("select"):
		is_dragging = false
