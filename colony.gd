class_name Colony
extends Marker2D

@export var queen_scene: PackedScene
@export var ant_scene: PackedScene
@export var colony_size: int = 100

func _ready():
	spawn_queen()
	for i in colony_size:
		spawn_ant()

func spawn_ant():
	var ant = ant_scene.instantiate()
	ant.position = self.position
	ant.colony_location = self
	print("ant time! ", ant)
	add_child(ant)

func spawn_queen():
	pass # TODO spawn a queen
