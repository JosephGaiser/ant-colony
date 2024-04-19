class_name SoldierAnt
extends CharacterBody2D

@export var colony: Colony
@export var current_state: AntState = AntState.PATROLLING
@export var previous_state: AntState = AntState.IDLE
@export var move_speed: float = 100.0
@export var lerp_speed: float = 0.2
# Random walk variables
@export var patrol_range: float = 500.00
@export var persuit_range: float = 800.00
#Nav variables
@export var path_desired_distance: float = 20 # How close must be to target location to consider "reached"
@export var target_desired_distance: float = 50 # How far from target location csan be before recalc path
@export var outline_component: OutlineComponent

# References to other nodes
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D
@onready var vision = %Vision

# Internal variables
var movement_target_position: Vector2 = Vector2(0.0, 0.0)
var target_enemy: Node2D
var current_angle: float              = 0.0
var attack: Attack                    = Attack.new()
# Enum for Ant states
enum AntState {
	PATROLLING,
	RETURNING_TO_NEST,
	DEFENDING_NEST,
	IN_COMBAT,
	IDLE,
}


func _ready():
	if colony:
		outline_component.set_line_color(colony.color)
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
		AntState.PATROLLING:
			patrol()
		AntState.DEFENDING_NEST:
			defend_nest()
		AntState.IN_COMBAT:
			combat()
		AntState.IDLE:
			pass

	if navigation_agent.is_navigation_finished():
		return
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var direction_to_move: Vector2  = global_position.direction_to(next_path_position)
	#    var new_velocity: Vector2  = lerp(velocity, direction_to_move * move_speed, lerp_speed)
	var new_velocity: Vector2 = direction_to_move * move_speed
	rotation = lerp(rotation, direction_to_move.angle(), lerp_speed)
	if navigation_agent.avoidance_enabled:
		# Avoidance is enabled, so we need to set the velocity through the navigation agent.
		navigation_agent.set_velocity(new_velocity)
	else:
		# Avoidance is disabled, so we can set the velocity directly.
		_on_navigation_agent_2d_velocity_computed(new_velocity)

func get_colony() -> Colony:
	return colony

func random_patrol():
	# walk around the colony in a random pattern but stay close to the nest
	var angle_range: float      = 45.0
	var distance_range: Vector2 = Vector2(50.00, patrol_range)
	current_angle += randf_range(-angle_range, angle_range)
	var distance: float         = randf_range(distance_range.x, distance_range.y)
	var target: Vector2         = colony.global_position + Vector2(cos(current_angle), sin(current_angle)) * distance
	set_movement_target(target)


# State logic
func set_state(state: AntState) -> void:
	if state == current_state:
		return # Don't change state if it's the same
	print("new state", state, "last state", previous_state)
	previous_state = current_state
	current_state = state


func patrol() -> void:
	if navigation_agent.is_navigation_finished():
		random_patrol()


func return_to_nest() -> void:
	if colony == null:
		set_state(AntState.IDLE)
		return
	set_movement_target(colony.global_position)
	if navigation_agent.is_navigation_finished():
		set_state(AntState.PATROLLING)


func combat() -> void:
	if global_position.distance_to(colony.global_position) > persuit_range:
		target_enemy = null
		set_state(AntState.RETURNING_TO_NEST)
		return
	if target_enemy == null:
		var bodies: Array[Node2D] = vision.get_overlapping_bodies()
		if bodies.is_empty():
			set_state(AntState.PATROLLING)
			return
		for body in bodies:
			if body is Ant:
				target_enemy = body
	set_movement_target(target_enemy.global_position)


func defend_nest() -> void:
	pass


func see_enemy(body) -> void:
	if body is Ant || SoldierAnt || QueenAnt:
		if target_enemy == null:
			target_enemy = body # Set the first enemy seen as the target
	set_state(AntState.IN_COMBAT)


func lost_enemy(ant: Ant):
	target_enemy = null
	set_state(AntState.PATROLLING)


func _on_vision_body_entered(body) -> void:
	if body.is_in_group("ant"):
		if body.colony == colony:
			return # Ignore ants from the same colony
		see_enemy(body)


func _on_vision_body_exited(body):
	if body is Ant:
		if body.colony == colony:
			return # Ignore ants from the same colony
		lost_enemy(body)


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()
