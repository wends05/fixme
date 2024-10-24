extends Node2D 

@onready var rightDoor = $RightDoor
@onready var leftDoor = $LeftDoorCutscene
@onready var playButton = $playButton  

func _ready() -> void:

	playButton.pressed.connect(_on_button_pressed) 


	open_doors()


func open_doors() -> void:
	var tween = create_tween()

	tween.tween_property(rightDoor, "position", Vector2(1152, rightDoor.position.y), 1.2).set_ease(Tween.EASE_IN_OUT)

	tween.set_parallel()
	tween.tween_property(leftDoor, "position", Vector2(-576, leftDoor.position.y), 2).set_ease(Tween.EASE_IN_OUT)

# Function to close the doors
func closed_doors() -> Tween:
	var tween = create_tween()

	tween.tween_property(rightDoor, "position", Vector2(584, rightDoor.position.y), 1.2).set_ease(Tween.EASE_IN_OUT)

	tween.set_parallel()
	tween.tween_property(leftDoor, "position", Vector2(576, leftDoor.position.y), 2).set_ease(Tween.EASE_IN_OUT)
	return tween 


func _on_button_pressed() -> void:

	var tween = closed_doors()
	await tween.finished

	get_tree().change_scene_to_file("res://scenes/select_2.tscn")
