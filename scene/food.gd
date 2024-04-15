class_name Food
extends RigidBody2D

@export var value: int = 1
@export var weight: float = 1.0

@onready var coll: CollisionShape2D = %CollisionShape2D


func _ready():
	mass = weight

func pickup():
	print("I was picked up", self)
	queue_free()


func drop(position: Vector2):
	print("I was dropped", self)


func get_weight() -> float:
	return weight


func get_value() -> int:
	return value
