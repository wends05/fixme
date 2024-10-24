extends Node2D

@onready var rightDoor = $RightDoor
@onready var leftDoor = $LeftDoor
@export var hand : Hand
var server := UDPServer.new()

# Called when the new scene is ready
func _ready() -> void:
	open_doors()
	server.listen(4523)

func _process(delta: float) -> void:
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

# Function to open the doors
func open_doors() -> void:
	rightDoor.visible = true
	leftDoor.visible = true
	await get_tree().create_timer(1.0).timeout  # Pause for 1 second
	var tween = create_tween()
	# Animate right door opening to position (1152)
	tween.tween_property(rightDoor, "position", Vector2(1152, rightDoor.position.y), 1.2)
	# Animate left door opening to position (-576)
	tween.set_parallel()
	tween.tween_property(leftDoor, "position", Vector2(0, leftDoor.position.y), 1.2)

func closed_doors() -> Tween:
	var tween = create_tween()
	tween.tween_property(rightDoor, "position", Vector2(576, rightDoor.position.y), 1.2)
	tween.set_parallel()
	tween.tween_property(leftDoor, "position", Vector2(576, leftDoor.position.y), 1.2)
	return tween

func _on_fruits_toggled(toggled_on: bool) -> void:
	await closed_doors().finished
	get_tree().change_scene_to_file("res://scenes/game (fv).tscn")
	globals.background = preload("res://assets/Fruits and Veggies BG.png")

func _on_drinks_toggled(toggled_on: bool) -> void:
	await closed_doors().finished
	get_tree().change_scene_to_file("res://scenes/game (ds).tscn")
	globals.background = preload("res://assets/section_1_bg.png")
