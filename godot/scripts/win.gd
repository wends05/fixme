extends Node2D


@onready var bg : TextureRect = $background
@onready var winloseDisplay : TextureRect = $Control/Display
@onready var stats : Label = $Control/Stats
@export var hand : Hand
@onready var rightDoor = $RightDoor
@onready var leftDoor = $LeftDoor

var winMessages = [
	"The shelf is so organized, it's making the other furniture jealous",
	"Your shelf is now more organized than my life choices",
	"Even the expired energy drinks are impressed with your energy",
	"Customer review: 'Those shelves are so neat, I feel bad messing them up'"
]
var loseMessages = [
	"The items on the shelf are now officially in witness protection",
	"Legend says those boxes are still waiting to be stocked...",
	"The products are now playing musical chairs on their own",
	"No"
]

var server := UDPServer.new()

func _ready() -> void:
	#bg.texture = globals.background
	if globals.win:
		setupWin()
	else:
		setupLose()

	server.listen(4523)
	open_doors()

func _process(_delta: float) -> void:
	server.poll()
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		var packet = peer.get_packet()

		var data: String = JSON.parse_string(packet.get_string_from_utf8()).position
		var getting = JSON.parse_string(packet.get_string_from_utf8()).getting
		var x = data.split(",")[0].to_float() * get_window().size.x
		var y = data.split(",")[1].to_float() * get_window().size.y

		globals.hand_data = {
			"getting": getting,
			"position": {
				"x": x,
				"y": y
			}
		}
		#print(globals.hand_data)

		hand.move(x, y)
		if getting:
			hand.close()
		else:
			hand.open()

func setupWin():
	winloseDisplay.texture = preload("res://assets/win.png")
	stats.text = winMessages.pick_random()
	stats.text += "\nTime Left: %s" % globals.time_left

func setupLose():
	winloseDisplay.texture = preload("res://assets/gameover.png")
	stats.text = loseMessages.pick_random()
	stats.text += "\nItems arranged: %s" % globals.score

func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		await closed_doors().finished
		get_tree().change_scene_to_file("res://scenes/select.tscn")

func open_doors() -> void:
	rightDoor.visible = true
	leftDoor.visible = true
	var tween = create_tween()
	tween.tween_property(rightDoor, "position", Vector2(1152, rightDoor.position.y), 1.2)
	tween.set_parallel()
	tween.tween_property(leftDoor, "position", Vector2(0, leftDoor.position.y), 1.2)

# Function to close the doors
func closed_doors() -> Tween:
	var tween = create_tween()
	tween.tween_property(rightDoor, "position", Vector2(576, rightDoor.position.y), 1.2)
	tween.set_parallel()
	tween.tween_property(leftDoor, "position", Vector2(576, leftDoor.position.y), 1.2)
	return tween
