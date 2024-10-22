extends Node2D


@onready var rightDoor = $RightDoor
@onready var leftDoor = $LeftDoorCutscene
func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(rightDoor, "position", Vector2(576, rightDoor.position.y), 0.5).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel()
	tween.tween_property(leftDoor, "position", Vector2(576, leftDoor.position.y), 0.5).set_ease(Tween.EASE_IN_OUT)
