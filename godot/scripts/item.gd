extends Node2D

class_name Item

@onready var texture : TextureRect = $Texture
@onready var hitbox : Area2D = $Hitbox
@export var ui: UI


func _ready() -> void:
	ui.guide_opened.connect(disable_collisions)
	ui.guide_closed.connect(enable_collisions)

func disable_collisions():
	hitbox.set_collision_layer_value(2, false)

func enable_collisions():
	hitbox.set_collision_layer_value(2, true)
