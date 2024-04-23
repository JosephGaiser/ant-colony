class_name DigComponent
extends Node


@export var line_of_sight1: RayCast2D
@export var line_of_sight2: RayCast2D
@export var line_of_sight3: RayCast2D

@export var replacement_cell: Vector2i = Vector2i(4,6) # Floor Atlas Coords


func _process(delta):
	check_los(line_of_sight1)
	check_los(line_of_sight2)
	check_los(line_of_sight3)

func check_los(line_of_sight: RayCast2D):
	if line_of_sight.is_colliding():
		var col: Object = line_of_sight.get_collider()
		if col is TileMap:
			dig(col, line_of_sight)

func dig(tile_map: TileMap, los: RayCast2D) -> void:
	var tile_pos: Vector2 = tile_map.local_to_map(los.get_collision_point())
	tile_map.set_cell(0, tile_pos, 0, replacement_cell)
