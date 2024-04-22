extends Node2D


@export var colony: Colony


func _on_food_storage_body_entered(body):
	if body is Food:
		body.set_collected(true, colony)
	if body is Ant:
		body.deposit_food(colony)


func _on_food_storage_body_exited(body):
	if body is Food:
		body.set_collected(true, colony)
	if body is Ant:
		body.deposit_food(colony)
