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
var win = false
signal scoreIncreased

func increaseScore():
	score += 1
	scoreIncreased.emit()
