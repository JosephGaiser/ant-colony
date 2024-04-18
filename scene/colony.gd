class_name Colony
extends Marker2D

@export var queen_scene: PackedScene
@export var ant_scene: PackedScene
@export var colony_size: int = 0

@onready var food_storage: Marker2D = %FoodStorageMarker
@onready var waste_storage: Marker2D = %WasteStorageMarker
@onready var spawn_location: Marker2D = %SpawnLocationMarker
@onready var food_storage_label = %FoodStorageLabel

var food_storage_inventory: Array[Food] = []


func get_storage_location() -> Vector2:
	return food_storage.global_position


func get_waste_location() -> Vector2:
	return waste_storage.global_position


func get_spawn_location() -> Vector2:
	return spawn_location.global_position


func spawn_ant(scene):
	var ant = scene.instantiate()
	ant.position = self.global_position
	ant.colony = self
	add_child(ant)


func spawn_queen():
	spawn_ant(queen_scene)


func deposit_food(food: Food):
	var dupe: Food = food.duplicate()
	food.deposit() # remove from world
	food_storage_inventory.append(dupe)
	food_storage_label.text = str(food_storage_inventory.size())


func _on_food_storage_body_entered(body):
	if body is Food:
		body.set_collected(true, self)
	if body is Ant:
		body.deposit_food(self)
