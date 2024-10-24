extends Control


class_name UI
@onready var guideBG = $GuideBG
@onready var GuideSheet = $GuideBG/GuideSheet
@onready var timer_label = $Timer/TimerLabel
@export var timer: Timer

signal timer_ended
signal guide_opened
signal guide_closed

func _ready() -> void:
	$GuideBG.visible = false
	timer.start(120)
	await timer.timeout
	timer_ended.emit()

func _process(delta: float) -> void:
	timer_label.text = "%s" % ceili(timer.time_left)

func _on_guide_button_pressed() -> void:
	print("opendnnignsndnsnaksd")


func _on_guide_button_button_down() -> void:
	print("button down lol")


func _on_guide_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		guideBG.visible = true
		$"Close Guide".visible = true
		$"Guide Button".visible = false
		guide_opened.emit()

func _on_close_guide_toggled(toggled_on: bool) -> void:
	if toggled_on:
		guideBG.visible = false
		$"Close Guide".visible = false
		$"Guide Button".visible = true
		guide_closed.emit()
func pause():
	pass

func resume():
	pass

func restart():
	pass

func quit():
	pass
