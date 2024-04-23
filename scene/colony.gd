class_name Colony
extends Node2D

@export var queen_scene: PackedScene
@export var worker_scene: PackedScene
@export var soldier_scene: PackedScene
@export var colony_size: int = 0
@export var color: Color = Color.GOLDENROD
@export var colony_name: String = "default"

#Components
@export var outline_component: OutlineComponent

#OnReady
@onready var food_storage: Node2D = %FoodStorageMarker
@onready var waste_storage: Marker2D = %WasteStorageMarker
@onready var spawn_location: Marker2D = %SpawnLocationMarker
@onready var food_storage_label: Label = %FoodStorageLabel

var food_storage_inventory: Array[Food] = []


func _ready():
	outline_component.set_line_color(color)
	spawn_ant(queen_scene)
	spawn_ant(soldier_scene)
	spawn_ant(soldier_scene)	
	for i in colony_size - 1:
		spawn_ant(worker_scene)

func get_storage_location() -> Vector2:
	return food_storage.global_position


func get_waste_location() -> Vector2:
	return waste_storage.position


func get_spawn_location() -> Vector2:
	return spawn_location.position


func spawn_ant(scene):
	var ant = scene.instantiate()
	ant.position = get_spawn_location()
	ant.colony = self
	ant.add_to_group(colony_name)
	colony_size += 1
	print("spawning ", ant, "at pos", ant.position)
	add_child(ant)


func deposit_food(food: Food):
	var dupe: Food = food.duplicate()
	food.deposit() # remove from world
	food_storage_inventory.append(dupe)
	food_storage_label.text = str(food_storage_inventory.size())


func withdraw_food() -> Food:
	food_storage_label.text = str(food_storage_inventory.size() - 1)
	return food_storage_inventory.pop_back()


func get_details() -> Array[Dictionary]:
	return [
		{"name": "Colony Size", "value": str(colony_size)},
		{"name": "Food Storage", "value": str(food_storage_inventory.size())},
	]
