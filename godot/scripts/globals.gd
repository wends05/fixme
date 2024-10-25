extends Node


var hand_data = {
	"getting": false,
	"position": {
		"x": "",
		"y": ""
	}
}

var score: int = 0
var time_left: int = 0
var win = true

var background = preload("res://assets/section_1_bg.png")

signal scoreIncreased

func increaseScore():
	score += 1
	scoreIncreased.emit()
