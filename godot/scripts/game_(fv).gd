class_name GameFV
extends Node2D

var apples = preload("res://assets/items/fruits and veggies/apples.png")
var banana = preload("res://assets/items/fruits and veggies/banana.png")
var brocolli = preload("res://assets/items/fruits and veggies/brocolli.png")
var cabbage = preload("res://assets/items/fruits and veggies/cabbage.png")
var carrot = preload("res://assets/items/fruits and veggies/carrot.png")
var cucumber = preload("res://assets/items/fruits and veggies/cucumber.png")
var grapes = preload("res://assets/items/fruits and veggies/Grapes (1).png")
var mango = preload("res://assets/items/fruits and veggies/mango.png")
var pineapple = preload("res://assets/items/fruits and veggies/pineapple.png")
var squash = preload("res://assets/items/fruits and veggies/squash (1).png")

var items: Array[Resource] = [apples, banana, brocolli, cabbage, carrot, cucumber, grapes, mango, pineapple, squash]


var server := UDPServer.new()
@export var hand : Hand
@export var UI : UI

var timer_ended = false


func _ready():
	server.listen(4523)
	readyItems()
	readyShelfandGuide()
	UI.timer_ended.connect(end_game)

func end_game():
	timer_ended = true
	print_verbose("timer ended")
func _process(_delta):
	if timer_ended: return

	server.poll()
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		var packet = peer.get_packet()
		#print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		#print("Received data: %s" % [packet.get_string_from_utf8()])

		var data : String = JSON.parse_string(packet.get_string_from_utf8()).position
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

		hand.move(x, y)
		hand.close() if getting else hand.open()

func readyItems():
	items.shuffle()
	# change to a proper class later
	var textures : Array = []
	for txt in items:
		var item : Item = preload("res://scenes/items/item.tscn").instantiate()
		if item.get_node("Texture"):
			var item_texture = item.get_node("Texture")
			item_texture.texture = txt
		textures.append(item)

	for i in range(10):
		$Items/Box_Items.get_children()[i].add_child(textures[i])

func readyShelfandGuide():
	items.shuffle()

	var slots : Array = []
	for txt in items:
		var slot : ShelfSlot = preload("res://scenes/items/shelf_slot.tscn").instantiate()
		slot.slot_texture = txt

		var s_Texture : TextureRect = slot.get_node("Texture")
		if s_Texture:
			s_Texture.texture = txt
			slot.visible = false
		slots.append(slot)
	for i in range(9):
		$"Items/Shelf Items".get_children()[i].add_child(slots[i])
		UI.GuideSheet.get_children()[i].texture = items[i]
		for texture_rect in UI.GuideSheet.get_children():
			texture_rect.scale = Vector2(2,2)
