class_name Colony
extends Marker2D

@export var queen_scene: PackedScene
@export var ant_scene: PackedScene
@export var colony_size: int = 0
@onready var food_storage: Marker2D = %FoodStorage

var food_storage_size: Vector2 = Vector2(100, 100)

func _ready():
	spawn_queen()
	for i in colony_size:
		spawn_ant()


func get_storage_location() -> Vector2:
	return food_storage.global_position

func spawn_ant():
	var ant = ant_scene.instantiate()
	ant.position = self.position
	ant.colony_location = self
	print("ant time! ", ant)
	add_child(ant)

func spawn_queen():
	pass # TODO spawn a queen


func _on_area_2d_body_entered(body):
	if body is Food:
		body.set_collected(true, self)
		print("collected food!")


func _on_area_2d_body_exited(body):
	if body is Food:
		body.set_collected(false, null)
		print("lost food!")
