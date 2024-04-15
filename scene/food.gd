class_name Food
extends RigidBody2D

@export var value: int = 1
@export var weight: float = 1.0

@onready var sprite = %Sprite2D
@onready var collision: CollisionShape2D = %CollisionShape2D

var held_by = null
var collected: bool = false


func _integrate_forces(state):
	if held_by != null:
		var t = state.get_transform()
		var new_pos = held_by.global_position + Vector2(0, -20)
		t.origin.x = new_pos.x
		t.origin.y = new_pos.y
		state.set_transform(t) 


func _ready():
	mass = weight


func pickup(picker_upper):
	print("I was picked up by ", picker_upper)
	collision.set_deferred("disabled", true)
	held_by = picker_upper


func drop():
	print("I was dropped", self)
	#collision.set_deferred("disabled", false) TODO 
	held_by = null


func set_collected(value: bool) -> void:
	collected = value


func is_collected() -> bool:
	return collected


func get_weight() -> float:
	return weight


func get_value() -> int:
	return value
