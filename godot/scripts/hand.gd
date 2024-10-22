extends TextureRect

class_name Hand



func move(x: int, y: int):
	position = Vector2(x, y)

func hover():
	self.flip_v = true

func not_hovering():
	self.flip_v = false
