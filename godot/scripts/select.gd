extends Node2D

@onready var rightDoor = $RightDoor
@onready var leftDoor = $LeftDoorCutscene

# Called when the node enters the scene tree (scene starts/changes to this one)
func _ready() -> void:
	open_doors()

# Called just before the node (scene) is removed from the scene tree (scene change)
func _exit_tree() -> void:
	closed_doors()

# Function to open the doors
func open_doors() -> void:
	var tween = create_tween()
	# Animate right door opening to position (1152)
	tween.tween_property(rightDoor, "position", Vector2(1152, rightDoor.position.y), 0.7).set_ease(Tween.EASE_IN_OUT)
	# Animate left door opening to position (-576)
	tween.set_parallel()
	tween.tween_property(leftDoor, "position", Vector2(-576, leftDoor.position.y), 0.9).set_ease(Tween.EASE_IN_OUT)

# Function to close the doors
func closed_doors() -> Tween:
	var tween = create_tween()
	# Animate right door closing to position (576)
	tween.tween_property(rightDoor, "position", Vector2(576, rightDoor.position.y), 0.9).set_ease(Tween.EASE_IN_OUT)
	# Animate left door closing to position (576)
	tween.set_parallel()
	tween.tween_property(leftDoor, "position", Vector2(576, leftDoor.position.y), 0.9).set_ease(Tween.EASE_IN_OUT)
	return tween # Return the tween object so we can connect to its `finished` signal

# Called when a button is pressed to change scenes
func _on_button_pressed() -> void:
	# Close doors and wait for the tween to finish before changing the scene
	var tween = closed_doors()
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/select_2.tscn")
