class_name PickableComponent
extends Node2D

@export var pickable: bool = true

# offset the position of the pickable node to be in front of the entity that is holding it
# adjust the offset based on the size of the holder
var offset: Vector2 = Vector2(0, 0)
var held_by         = null


func pickup(picker_upper: Node2D, new_offset: Vector2):
	if !pickable:
		return
	held_by = picker_upper
	pickable = false # disable the pickable node so it can't be picked up again
	offset = new_offset


func drop():
	held_by = null
	pickable = true # enable the pickable node so it can be picked up again
	offset = Vector2(0, 0)


func get_held_by():
	return held_by
	
func is_held():
	if held_by == null:
		return false
	return true

func get_held_position():
	return held_by.global_position + offset

func integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if held_by == null:
		return
	var t: Transform2D = state.get_transform()
	var new_pos = held_by.global_position + offset
	t.origin.x = new_pos.x
	t.origin.y = new_pos.y
	state.set_transform(t)
