class_name Food
extends RigidBody2D

@export var value: int = 1
@export var weight: float = 1.0

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var coll: CollisionShape2D = %CollisionShape2D


func _ready():
	mass = weight / 10

func pickup():
	print("I was picked up", self)
	queue_free()


func drop(position: Vector2):
	print("I was dropped", self)
	# TODO FIX
	queue_free()


func get_weight() -> float:
	return weight


func get_value() -> int:
	return value
