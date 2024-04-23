class_name QueenAnt
extends CharacterBody2D

signal queen_is_hungry(queen: QueenAnt)

# Ant properties
@export var colony: Colony
@export var current_state: AntState = AntState.RETURNING_TO_NEST
@export var previous_state: AntState = AntState.IDLE
@export var move_speed: float = 30.0
@export var lerp_speed: float = 0.2
@export var carry_capacity: float = 1.0
@export var is_leader: bool = false
@export var pickup_offset: Vector2 = Vector2(0, -20)
@export var worker_scene: PackedScene
@export var soldier_scene: PackedScene

# Random walk variables
@export var random_walk_distance: float = 50.00
#Nav variables
@export var path_desired_distance: float = 20 # How close must be to target location to consider "reached"
@export var target_desired_distance: float = 50 # How far from target location csan be before recalc path
@export var outline_component: OutlineComponent

# References to other nodes
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D
@onready var hunger_component = %HungerComponent

# Internal variables
var movement_target_position: Vector2    = Vector2(0.0, 0.0)
var carry_weight: float                  = 0.0
var current_angle: float                 = 0.0
var inventory: Array[Food]               = []
var known_food_locations: Array[Vector2] = []
var spawn_timer: Timer
# Enum for Ant states
enum AntState {
	RETURNING_TO_NEST,
	SPAWNING_ANTS,
	IDLE,
}


func _ready():
	if colony:
		outline_component.set_line_color(colony.color)

	# Setup spawning timer
	spawn_timer = Timer.new()
	spawn_timer.set_wait_time(10)
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = path_desired_distance
	navigation_agent.target_desired_distance = target_desired_distance
	navigation_agent.avoidance_enabled = true

	# Make sure to not await during _ready.
	call_deferred("actor_setup")


func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	# Now that the navigation map is no longer empty, set the movement target to the current position.
	set_movement_target(global_position)


func set_movement_target(movement_target: Vector2):
	movement_target_position = movement_target
	navigation_agent.target_position = movement_target


func _physics_process(delta) -> void:
	match current_state:
		AntState.RETURNING_TO_NEST:
			return_to_nest()
		AntState.SPAWNING_ANTS:
			spawning()
		AntState.IDLE:
			if navigation_agent.is_navigation_finished():
				random_walk()

	if navigation_agent.is_navigation_finished():
		return
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var direction_to_move: Vector2  = global_position.direction_to(next_path_position)
	var new_velocity: Vector2 = direction_to_move * move_speed
	rotation = lerp(rotation, direction_to_move.angle(), lerp_speed)
	if navigation_agent.avoidance_enabled:
		# Avoidance is enabled, so we need to set the velocity through the navigation agent.
		navigation_agent.set_velocity(new_velocity)
	else:
		# Avoidance is disabled, so we can set the velocity directly.
		_on_navigation_agent_2d_velocity_computed(new_velocity)


# State logic
func set_state(state: AntState) -> void:
	if state == current_state:
		return # Don't change state if it's the same
	previous_state = current_state
	current_state = state

func spawning():
	if hunger_component.is_hungry():
		queen_is_hungry.emit(self)
	set_movement_target(colony.spawn_location.global_position)

func random_walk():
	var angle_range: float      = 45.0
	var distance_range: Vector2 = Vector2(50.00, random_walk_distance)
	current_angle += randf_range(-angle_range, angle_range)
	var distance: float         = randf_range(distance_range.x, distance_range.y)
	var target: Vector2         = colony.spawn_location.global_position + Vector2(cos(current_angle), sin(current_angle)) * distance
	set_movement_target(target)


func return_to_nest() -> void:
	if colony == null:
		set_state(AntState.IDLE) #TODO Esablish a new colony?
		return
	if navigation_agent.is_navigation_finished():
		set_state(AntState.SPAWNING_ANTS)
		return
	set_movement_target(colony.get_spawn_location())


# Signals
func _on_reach_body_entered(body) -> void:
	pass


func _on_vision_body_entered(body) -> void:
	pass


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()


func _on_spawn_timer_timeout():
	print("Spawn timer timeout")
	if current_state == AntState.SPAWNING_ANTS:
		colony.spawn_ant(worker_scene)
		hunger_component.burn_hunger(10.0)


# Used for detailed information about the ant in the UI
func get_details() -> Array[Dictionary]:
	return [
		{"name": "Current State", "value": AntState.find_key(current_state)},
		{"name": "Position", "value": str(global_position)},
		{"name": "Velocity", "value": str(velocity)},
		{"name": "Rotation", "value": str(rotation)},
		{"name": "Carry Weight", "value": str(carry_weight)},
		{"name": "Inventory", "value": str(inventory)},
		{"name": "Seen Food", "value": str(known_food_locations)},
		{"name": "Random Walk Distance", "value": str(random_walk_distance)},
	]
