class_name Ant
extends CharacterBody2D

@export var move_speed: int = 100
@export var lerp_speed: float = 0.1  # Adjust this value to control the speed of interpolation
@export var rotation_speed: float = 0.05  # Adjust this value to control the speed of rotation
@export var carry_capacity: float = 100.00 # Adjust this value to control the carry capacity

@onready var reach: Area2D = %Reach # Reference to the players reach area
@onready var vision: Area2D = %Vision # Reference to the players vision area

var target                = null # The target the player is moving towards
var inventory: Dictionary = {} # The players inventory


func _on_reach_body_entered(body):
    if body.is_in_group("food"):
        pass


func _on_vision_body_entered(body):
    pass
