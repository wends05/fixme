extends TextureRect

class_name Hand
var item : Item
var slot : ShelfSlot
@onready var grabbed_texture = $texture

@export var calibrateX: float
@export var calibrateY: float = -120

var closeHand = preload("res://assets/closedhands.png")
var openHand = preload("res://assets/openhands.png")


func move(x: int, y: int):
	position = Vector2(x + calibrateX, y + calibrateY)

func close():
	texture = closeHand

func open():
	texture = openHand

func _ready() -> void:
	texture = openHand

func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_instance_of(area.get_parent(), Item):
		if globals.hand_data.get("getting") and not grabbed_texture.texture:
			item = area.get_parent()
			grabbed_texture.texture = item.texture.texture
			item.texture.texture = null
			print("IS ITEM")

	if is_instance_of(area.get_parent(), ShelfSlot):
		if globals.hand_data.get("getting"):
			slot = area.get_parent()
			print("IS SLOT")

func _on_area_2d_area_exited(area: Area2D) -> void:
	if is_instance_of(area.get_parent(), ShelfSlot) and \
		globals.hand_data.get("getting") and \
		area.get_parent() == slot:
			slot = null


func _process(_delta: float) -> void:

	if not grabbed_texture.texture:
		return

	if not globals.hand_data.get("getting"):
		if slot:
			if not slot.texture.texture == grabbed_texture.texture:
				print("NOT MATCH")
				item.texture.texture = grabbed_texture.texture
				grabbed_texture.texture = null
			#elif slot.texture.texture == txt.texture:
			else:
				print("omg it match")
				grabbed_texture.texture = null
				slot.texture.visible = true
				globals.increaseScore()

			print(slot.texture.texture, " ", grabbed_texture.texture)
			print("Trying to drop in the slot")
		else:
			print("No slot")
			item.texture.texture = grabbed_texture.texture
			grabbed_texture.texture = null
