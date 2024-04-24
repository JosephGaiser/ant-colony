class_name Food
extends RigidBody2D

@export var value: int = 10
@export var weight: float = 1.0
@export var pickable_component: PickableComponent

var collected: bool      = false
var collected_by: Colony = null


func set_collected(val: bool, collector: Colony) -> void:
	collected = val
	collected_by = collector


func is_held() -> bool:
	return pickable_component.is_held()


func pickup(picker_upper: Node2D, offset: Vector2):
	pickable_component.pickup(picker_upper, offset)
	set_freeze_enabled(true)


func drop():
	pickable_component.drop()
	set_freeze_enabled(false)


func is_collected_by_colony(colony: Colony) -> bool:
	if colony == collected_by:
		return true
	return false


func get_weight() -> float:
	return weight


func get_value() -> int:
	return value


func deposit():
	queue_free()


func consumed_by(consumer):
	queue_free()

func _process(delta):
	# If the food is held, update its position to the picker upper's position
	if pickable_component.is_held() && freeze == true:
		position = pickable_component.get_held_position()
