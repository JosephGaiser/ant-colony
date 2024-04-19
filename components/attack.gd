class_name Attack
extends Node

@export var attack_damage: float = 1.0
@export var knockback_force: float = 250.0
@export var attack_position: Vector2 = Vector2(0, 0) # Used to determine the direction of the knockback
@export var cooldown: float = 2.0
