class_name DigComponent
extends Node

@export var dig_cooldown: float = 3.0
@export var line_of_sight: RayCast2D

var dig_timer: Timer

func _ready():
	dig_timer = Timer.new()
	dig_timer.set_wait_time(dig_cooldown)
	dig_timer.autostart = true


func _process(delta):
	if dig_timer.is_stopped():
		check_los(line_of_sight)


func check_los(line_of_sight: RayCast2D):
	if line_of_sight.is_colliding():
		var col: Object = line_of_sight.get_collider()
		if col is TileMap:
			dig(col, line_of_sight)
			dig_timer.start()


func dig(tile_map: TileMap, los: RayCast2D) -> void:
	var tile_pos: Vector2 = tile_map.local_to_map(los.get_collision_point())
	# replace walls with floor and update surrounding tiles
	tile_map.set_cells_terrain_connect(0, [tile_pos], 0, 1)
