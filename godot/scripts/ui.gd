extends Control


class_name UI

@onready var right_door = $RightDoor
@onready var left_door = $LeftDoor

@onready var guideBG = $GuideBG
@onready var GuideSheet = $GuideBG/GuideSheet
@onready var timer_label = $Timer/TimerLabel
@onready var main_menu = $"Main Menu"

@onready var guide_button : Btn = $"Guide Button"

@onready var pause_button : Btn = $"Pause Button"

@onready var resume_button : Btn = $"Main Menu/Resume"
@onready var restart_button : Btn = $"Main Menu/Restart"
@onready var exit_button : Btn = $"Main Menu/Quit"

@onready var manager : AnimatedSprite2D = $Tao/Manager
@onready var dialogue_box : Sprite2D = $Tao/DialogueBox
@onready var label : Label = $Tao/DialogueBox/Label

@onready var internal_timer : Timer = $"Internal Timer"

@export var timer: Timer
@export var items: Node2D
@export var box: TextureRect

var open_box = preload("res://assets/open_box.png")
var closed_box = preload("res://assets/closed_box.png")

signal timer_ended
signal guide_opened
signal guide_closed
signal is_paused
signal is_resumed

func _ready() -> void:
	$GuideBG.visible = false
	await openDoors()
	talk()
	playCountdown()

func openDoors() -> Tween:
	right_door.visible = true
	left_door.visible = true
	var tween = create_tween()
	tween.tween_property(right_door, "position", Vector2(1152, right_door.position.y), 1.2)
	tween.set_parallel()
	tween.tween_property(left_door, "position", Vector2(0, left_door.position.y), 1.2)
	await tween.finished
	right_door.visible = false
	left_door.visible = false
	return tween

func closeDoors() -> Tween:
	internal_timer.start(1)
	await internal_timer.timeout
	right_door.visible = true
	left_door.visible = true
	var tween = create_tween()
	tween.tween_property(right_door, "position", Vector2(576, right_door.position.y), 1.2)
	tween.set_parallel()
	tween.tween_property(left_door, "position", Vector2(576, left_door.position.y), 1.2)
	await tween.finished
	right_door.visible = false
	left_door.visible = false
	return tween

func talk():
	var text = "Supplies have arrived late, arrange them on the shelf before the store opens."

	internal_timer.start(4)
	await internal_timer.timeout
	dialogue_box.visible = true
	manager.play("talking")

	label.text = ""
	for c in text:
		label.text += c
		if c not in [",", ".", " "]:  # Simple array check
			internal_timer.start(0.07)
			await internal_timer.timeout

	manager.play("idle")
	internal_timer.start(2)
	await internal_timer.timeout
	$Tao.visible = false


func playCountdown():
	box.texture = closed_box
	items.visible = false
	$Countdown.visible = true
	$Countdown/CountdownTimer.start(3)
	await $Countdown/CountdownTimer.timeout
	$Countdown.visible = false
	box.texture = open_box
	items.visible = true
	timer.start(240)
	await timer.timeout
	timer_ended.emit()


func _process(_delta: float) -> void:
	timer_label.text = "%s" % ceili(timer.time_left)
	$Countdown/Label.text = "%s" % ceili($Countdown/CountdownTimer.time_left)


func _on_guide_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		guideBG.visible = true
		$"Close Guide".visible = true
		$"Guide Button".visible = false
		pause_button.visible = false
		guide_opened.emit()

func _on_close_guide_toggled(toggled_on: bool) -> void:
	if toggled_on:
		guideBG.visible = false
		$"Close Guide".visible = false
		$"Guide Button".visible = true
		pause_button.visible = true

		guide_closed.emit()

func togglePauseButtonCollision(isEnabled: bool):
	print_debug("isEnabled ", isEnabled)
	pause_button.collisionBounds.set_collision_layer_value(4, isEnabled)
	pause_button.collisionBounds.set_collision_mask_value(1, isEnabled)

func toggleMainMenuButtonCollisions(isEnabled: bool):
	var collisions = [
		resume_button.collisionBounds,
		restart_button.collisionBounds,
		exit_button.collisionBounds
	]
	for coll : Area2D in collisions:
		coll.set_collision_layer_value(4, isEnabled)
		coll.set_collision_mask_value(1, isEnabled)

func toggleGuideButtonCollision(isEnabled: bool):
	guide_button.collisionBounds.set_collision_layer_value(4, isEnabled)
	guide_button.collisionBounds.set_collision_mask_value(1, isEnabled)
	guide_button.visible = isEnabled


func _on_pause_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		timer.paused = true
		main_menu.visible = true
		pause_button.visible = false
		togglePauseButtonCollision(false)
		toggleMainMenuButtonCollisions(true)
		toggleGuideButtonCollision(false)
		is_paused.emit()

func _on_resume_toggled(toggled_on: bool) -> void:
	if toggled_on:
		timer.paused = false
		main_menu.visible = false
		pause_button.visible = true
		togglePauseButtonCollision(true)
		toggleMainMenuButtonCollisions(false)
		toggleGuideButtonCollision(true)
		is_resumed.emit()

func _on_restart_toggled(toggled_on: bool) -> void:
	if toggled_on:
		timer.paused = false
		pause_button.visible = true
		get_tree().reload_current_scene()
		togglePauseButtonCollision(true)
		toggleMainMenuButtonCollisions(false)
		toggleGuideButtonCollision(true)

		main_menu.visible = false

func _on_quit_toggled(toggled_on: bool) -> void:
	if toggled_on:
		timer.paused = false
		pause_button.visible = true
		togglePauseButtonCollision(true)
		toggleMainMenuButtonCollisions(false)
		toggleGuideButtonCollision(true)
		get_tree().change_scene_to_file("res://scenes/select.tscn")
		main_menu.visible = false
