class_name HealthComponent
extends Node2D

# HealthComponent is a simple component that adds health to a node.
# It can be used to add health to any node, such as a player, enemy, or projectile.
@export var max_health: int = 100
signal health_depleted
var health: int = max_health


# Decreases the health of the node by the given amount.
func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()


# Emits the health_depleted signal and removes the parent node from the scene.
func die() -> void:
	health_depleted.emit()
	get_parent().queue_free()
