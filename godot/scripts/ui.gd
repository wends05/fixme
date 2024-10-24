extends Control


class_name UI
@onready var guideBG = $GuideBG
@onready var GuideSheet = $GuideBG/GuideSheet
@onready var timer_label = $Timer/TimerLabel
@onready var main_menu = $"Main Menu"

@onready var guide_button : Btn = $"Guide Button"

@onready var pause_button : Btn = $"Pause Button"

@onready var resume_button : Btn = $"Main Menu/Resume"
@onready var restart_button : Btn = $"Main Menu/Restart"
@onready var exit_button : Btn = $"Main Menu/Quit"

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


func playCountdown():
	box.texture = closed_box
	items.visible = false
	$Countdown.visible = true
	$Countdown/CountdownTimer.start(3)
	await $Countdown/CountdownTimer.timeout
	$Countdown.visible = false
	box.texture = open_box
	items.visible = true
	timer.start(120)
	await timer.timeout
	timer_ended.emit()


func _process(delta: float) -> void:
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
	pause_button.collisionBounds.set_collision_layer_value(4, isEnabled)
	pause_button.collisionBounds.set_collision_mask_value(1, isEnabled)

func toggleMainMenuButtonCollisions(isEnabled: bool):
	var collisions = [
		pause_button.collisionBounds,
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

		main_menu.visible = false
