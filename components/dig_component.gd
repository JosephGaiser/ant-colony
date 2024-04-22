class_name DigComponent
extends Node


@export var line_of_sight: RayCast2D


func _process(delta):
	if line_of_sight.is_colliding():
		var col: Object = line_of_sight.get_collider()
		if col is TileMap:
			dig(col)

func dig(tile_map: TileMap) -> void:
	var tile_pos: Vector2 = tile_map.map_to_local(line_of_sight.get_collision_point())
