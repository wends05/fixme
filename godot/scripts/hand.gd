extends TextureRect

class_name Hand

func hover():
	self.flip_v = true

func not_hovering():
	self.flip_v = false
