extends Node2D

var draggable = false
var is_inside_droppable = false
var body_ref
var offset: Vector2
var initialPos : Vector2

func _process(_delta):
	if draggable:
		if Input.is_action_just_pressed("click"):
			initialPos = global_position
			offset = get_global_mouse_position() - global_position
			globals.is_dragging = true
		if Input.is_action_pressed("click"):
			global_position = get_global_mouse_position() - offset
		elif Input.is_action_just_released("click"):

			globals.is_dragging = false
			var tween = get_tree().create_tween()
			if is_inside_droppable:
				tween.tween_property(self,"position", body_ref.position,0.2).set_ease(Tween.EASE_OUT)
			else:
				tween.tween_property(self,"global_position",initialPos,0.2).set_ease(Tween.EASE_OUT)

# change later into hovered()
func _on_area_2d_mouse_entered():
	if not globals.is_dragging:
		draggable = true
		scale = Vector2(1.05, 1.05)

# unhovered
func _on_area_2d_mouse_exited():
	if not globals.is_dragging:
		draggable = false
		scale = Vector2(1,1)

# dropped
func _on_area_2d_body_entered(body: StaticBody2D):
	if body.is_in_group('dropable'):
		is_inside_droppable = true
		body.modulate = Color(Color.REBECCA_PURPLE, 1)
		body_ref = body

#
func _on_area_2d_body_exited(body):
	if body.is_in_group('dropable'):
		is_inside_droppable = false
		body.modulate = Color(Color.MEDIUM_PURPLE, 0.7)
