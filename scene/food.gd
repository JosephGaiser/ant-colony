class_name Food
extends RigidBody2D

@export var value: int = 1
@export var weight: float = 1.0
@export var pickable_component: PickableComponent

@onready var collision: CollisionShape2D = %CollisionShape2D

var collected: bool = false
var collected_by: Colony = null


func _ready():
	mass = weight


func set_collected(val: bool, collector: Colony) -> void:
	collected = val
	collected_by = collector


func pickup(picker_upper: Node2D, offset: Vector2):
	pickable_component.pickup(picker_upper, offset)
	collision.set_deferred("disabled", true)


func drop():
	pickable_component.drop()
	collision.set_deferred("disabled", false)


func is_collected_by_colony(colony: Colony) -> bool:
	if colony == collected_by:
		return true
	return false


func get_weight() -> float:
	return weight


func get_value() -> int:
	return value


func _integrate_forces(state):
	pickable_component.integrate_forces(state)
