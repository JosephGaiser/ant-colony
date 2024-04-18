class_name HitboxComponent
extends Node2D

@export var health_component: HealthComponent
@export var parent_body: CharacterBody2D

func is_friendly(colony: Colony) -> bool:
	if parent_body.colony == colony:
		return true
	return false
	
# Damage the entity if it has a health component
func damage(attack: Attack) -> void:
	if health_component:
		health_component.take_damage(attack.attack_damage)
	if parent_body:
		parent_body.velocity = (global_position - attack.attack_position).normalized() * attack.knockback_force
