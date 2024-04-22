class_name DetailedView
extends Control

@export var parent: Node
@onready var details: VBoxContainer = %Details

func _process(_delta: float) -> void:
	var props: Array[Dictionary] = parent.get_details()
	for property in props:
		if property['value'] == null:
			for child in details.get_children():
				if child is Label and child.name == property['name']: # Find the label with the same name
					child.hide() # Hide the label if the value is null
					break

		var label: Label = null
		for child in details.get_children():
			if child is Label and child.name == property['name']: # Find the label with the same name
				label = child # Set the label to the found label
				break

		if label == null: # If the label is not found, create a new one
			label = Label.new()
			label.name = property['name']
			details.add_child(label)

		label.show()
		label.text = property['name'] + ": " + str(property['value'])
