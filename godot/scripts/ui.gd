extends Control


class_name UI
@onready var guideBG = $GuideBG
@onready var GuideSheet = $GuideBG/GuideSheet
func _ready() -> void:
	$GuideBG.visible = false

func _on_guide_button_pressed() -> void:
	print("opendnnignsndnsnaksd")


func _on_guide_button_button_down() -> void:
	print("button down lol")


func _on_guide_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		guideBG.visible = true
		$"Close Guide".visible = true
		$"Guide Button".visible = false
func _on_close_guide_toggled(toggled_on: bool) -> void:
	if toggled_on:
		guideBG.visible = false
		$"Close Guide".visible = false
		$"Guide Button".visible = true
