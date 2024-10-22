extends TextureRect

class_name Hand
var item : Item
var slot : ShelfSlot
@onready var txt = $texture
func move(x: int, y: int):
	position = Vector2(x, y)

func hover():
	self.flip_v = true

func not_hovering():
	self.flip_v = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_instance_of(area.get_parent(), Item):
		print(item)
		if globals.hand_data.get("getting") and not txt.texture:
			item = area.get_parent()
			print("IS ITEM")
			txt.texture = item.texture.texture

	if is_instance_of(area.get_parent(), ShelfSlot):
		if globals.hand_data.get("getting"):
			slot = area.get_parent()
			print("IS SLOT")


func _process(delta: float) -> void:
	if not globals.hand_data.get("getting"):
		txt.texture = null

	if slot:
		print("Trying to drop in the slot")
