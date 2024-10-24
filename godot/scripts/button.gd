extends Button

class_name Btn
var hand: Hand = null
@onready var collisionBounds : Area2D = $Area2D
@export var hoverTexture: CompressedTexture2D
@export var normalTexture: CompressedTexture2D
func _process(_delta: float) -> void:
	if globals.hand_data.get("getting") and hand:
		button_pressed = true
	else:
		button_pressed = false

func _ready() -> void:
	collisionBounds.connect("area_entered", hover)
	collisionBounds.connect("area_exited", unhover)

func hover(area: Area2D):
	if is_instance_of(area.get_parent(), Hand):
		print("button on hand %s" % name)
		hand = area.get_parent()
		icon =  hoverTexture

func unhover(_area: Area2D):
	if hand:
		hand = null
		button_pressed = false
		icon = normalTexture
		print("hand is null")
