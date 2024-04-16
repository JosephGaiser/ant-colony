class_name HitboxComponent
extends Node2D

@export var health_component: HealthComponent

# Damage the entity if it has a health component
func damage(amount: int) -> void:
	#TODO damage effects
	if health_component:
		health_component.take_damage(amount)
