extends PanelContainer

@onready var details: VBoxContainer = %Details
@onready var ui: PanelContainer = %UI

var state_label: Label              = Label.new()
var target_label: Label             = Label.new()
var inventory_label: Label          = Label.new()
var leader_label: Label             = Label.new()
var followers_label: Label          = Label.new()
var ant_in_front_label: Label       = Label.new()
var distance_to_target_label: Label = Label.new()
var velocity_label: Label           = Label.new()


func _ready():
	details.add_child(state_label)
	details.add_child(target_label)
	details.add_child(inventory_label)
	details.add_child(followers_label)
	details.add_child(leader_label)
	details.add_child(ant_in_front_label)
	details.add_child(distance_to_target_label)
	details.add_child(velocity_label)


func update_detailed_view() -> void:
	ui.position = position + Vector2(10, 10) # Offset the UI from the ant
	if details.visible == false:
		return
	state_label.text = "State: " + AntState.find_key(current_state)
	target_label.text = "Target: " + str(target)
	inventory_label.text = "Inventory: " + str(inventory)
	followers_label.text = "Followers: " + str(followers)
	leader_label.text = "Leader: " + str(leader)
	ant_in_front_label.text = "Ant in front: " + str(ant_in_front)
	velocity_label.text = "Velocity: " + str(velocity)
	if target != null:
		distance_to_target_label.text = "Distance to target: " + str(global_position.distance_to(target))
		target_label.visible = true
	else:
		target_label.visible = false
	if inventory.is_empty():
		inventory_label.visible = false
	else:
		inventory_label.visible = true
	if followers.is_empty():
		followers_label.visible = false
	else:
		followers_label.visible = true
	if leader == null:
		leader_label.visible = false
	else:
		leader_label.visible = true
	if ant_in_front == null:
		ant_in_front_label.visible = false
	else:
		ant_in_front_label.visible = true
