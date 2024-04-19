class_name Ant
extends CharacterBody2D

# Ant properties
@export var colony: Colony
@export var current_state: AntState = AntState.SEARCHING
@export var previous_state: AntState = AntState.IDLE
@export var move_speed: float = 100.0
@export var lerp_speed: float = 0.2
@export var carry_capacity: float = 1.0
@export var pickup_offset: Vector2 = Vector2(0, -20)
# Random walk variables
@export var random_walk_distance: float = 500.00
#Nav variables
@export var path_desired_distance: float = 20 # How close must be to target location to consider "reached"
@export var target_desired_distance: float = 50 # How far from target location csan be before recalc path

# References to other nodes
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D

# Internal variables
var movement_target_position: Vector2    = Vector2(0.0, 0.0)
var carry_weight: float                  = 0.0
var current_angle: float                 = 0.0
var inventory: Array[Food]               = []
var known_food_locations: Array[Vector2] = []
var last_position: Vector2 = Vector2()
var stuck_timer: float = 0.0
var stuck_threshold: float = 3.0  # The ant is considered stuck if it stays in the same position for 3 seconds
# Enum for Ant states
enum AntState {
	SEARCHING,
	GOING_TO_TARGET,
	CARRYING_FOOD,
	RETURNING_TO_NEST,
	DEFENDING_NEST,
	IDLE,
}


func _ready():
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
		AntState.DEFENDING_NEST:
			defend_nest(delta)
		AntState.SEARCHING:
			search_for_food(delta)
		AntState.GOING_TO_TARGET:
			go_to_target()
		AntState.CARRYING_FOOD:
			carry_food()
		AntState.RETURNING_TO_NEST:
			return_to_nest()
		AntState.IDLE:
			pass

	# CHECK IF WE HAVE BEEN STUCK IN IN THIS LOCATION FOR MORE THAN A FEW SECONDS

	if global_position == last_position:
		stuck_timer += delta
		if stuck_timer > stuck_threshold:
			random_walk()
	else:
		stuck_timer = 0.0
		last_position = global_position

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


# State logic
func set_state(state: AntState) -> void:
	if state == current_state:
		return # Don't change state if it's the same
	previous_state = current_state
	current_state = state


func defend_nest(delta) -> void:
	if colony == null:
		set_state(AntState.SEARCHING)
		return
	if movement_target_position == colony.global_position:
		return # Don't change target if we're already there
	set_movement_target(colony.global_position)


func search_for_food(_delta) -> void:
	if !known_food_locations.is_empty(): # If we know about possible food locations, go to it
		set_state(AntState.GOING_TO_TARGET)
		return
	if navigation_agent.is_navigation_finished():
		random_walk()


func random_walk():
	var angle_range: float      = 45.0
	var distance_range: Vector2 = Vector2(100.00, random_walk_distance)
	current_angle += randf_range(-angle_range, angle_range)
	var distance: float         = randf_range(distance_range.x, distance_range.y)
	var target: Vector2         = global_position + Vector2(cos(current_angle), sin(current_angle)) * distance
	set_movement_target(target)


func go_to_target() -> void:
	if global_position.distance_to(movement_target_position) < 20:
		known_food_locations.erase(movement_target_position)
		set_state(AntState.SEARCHING)
	if !known_food_locations.is_empty(): # If we know about possible food locations, go to it
		var closest_food: Vector2 = known_food_locations[0]
		for food_position in known_food_locations:
			if global_position.distance_to(food_position) < global_position.distance_to(closest_food):
				closest_food = food_position
		set_movement_target(closest_food)
		return
	if !navigation_agent.is_target_reachable(): # If we can't reach the target, remove it from the list
		known_food_locations.erase(movement_target_position)
		set_state(AntState.SEARCHING)
		return


func carry_food():
	if carry_weight >= carry_capacity:
		set_state(AntState.RETURNING_TO_NEST)
	else:
		set_state(AntState.SEARCHING)


func return_to_nest() -> void:
	if colony == null:
		set_state(AntState.IDLE)
		return
	set_movement_target(colony.get_storage_location())
	if navigation_agent.is_navigation_finished():
		drop_all_food()
		set_state(AntState.SEARCHING)


# Food logic
func pickup_food(food: Food) -> void:
	known_food_locations.erase(food.global_position)
	if food.is_held():
		return
	food.pickup(self, pickup_offset)
	inventory.append(food)
	carry_weight += food.get_weight()
	set_state(AntState.CARRYING_FOOD)


func drop_all_food() -> void:
	for item in inventory:
		if item is Food:
			drop_food(item)


func drop_food(food: Food) -> void:
	inventory.erase(food)
	carry_weight -= food.get_weight()
	known_food_locations.erase(food.global_position)
	food.drop()


func deposit_food(deposit: Colony) -> void:
	if colony == null:
		drop_all_food()
		return
	if deposit != colony:
		return # Dont deposit in other colonies
	for item in inventory:
		if item is Food:
			inventory.erase(item)
			carry_weight -= item.get_weight()
			known_food_locations.erase(item.global_position)
			deposit.deposit_food(item)


func see_food(body):
	if !known_food_locations.has(body.global_position):
		known_food_locations.append(body.global_position)


# Signals
func _on_reach_body_entered(body) -> void:
	if body is Food:
		if body.is_collected_by_colony(colony):
			return # no action needed
		if carry_weight >= carry_capacity:
			return
		pickup_food(body)


func _on_vision_body_entered(body) -> void:
	if body is Food:
		if body.is_collected_by_colony(colony):
			return # no action needed
		see_food(body)


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()


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
