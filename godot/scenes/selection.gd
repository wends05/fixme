extends Node2D

@onready var rightDoor = $rightdoor
@onready var leftDoor = $leftdoor

# Called when the new scene is ready
func _ready() -> void:
	open_doors()

# Function to open the doors
func open_doors() -> void:
	await get_tree().create_timer(1.0).timeout  # Pause for 1 second
	var tween = create_tween()
	# Animate right door opening to position (1152)
	tween.tween_property(rightDoor, "position", Vector2(1168, rightDoor.position.y), 1.2).set_ease(Tween.EASE_IN_OUT)
	# Animate left door opening to position (-576)
	tween.set_parallel()
	tween.tween_property(leftDoor, "position", Vector2(-576, leftDoor.position.y), 1.2).set_ease(Tween.EASE_IN_OUT)
