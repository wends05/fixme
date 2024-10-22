class_name GameDS
extends Node2D

var biscoff = preload("res://assets/items/drinks and snacks/biscoff.png")
var c2 = preload("res://assets/items/drinks and snacks/c2.png")
var cheetos = preload("res://assets/items/drinks and snacks/cheetos.png")
var doritos = preload("res://assets/items/drinks and snacks/doritos.png")
var mayo = preload("res://assets/items/drinks and snacks/mayo.png")
var milk = preload("res://assets/items/drinks and snacks/milk.png")
var oreo = preload("res://assets/items/drinks and snacks/oreo.png")
var spam = preload("res://assets/items/drinks and snacks/spam.png")
var tinapay = preload("res://assets/items/drinks and snacks/tinapay.png")
var some_item = preload("res://assets/items/drinks and snacks/idkwhatthisis.png")

var items: Array[Resource] = [biscoff, c2, cheetos, doritos, mayo, milk, oreo, spam, tinapay, some_item]


var server := UDPServer.new()
@export var hand : Hand

#var final_items = {
	#0: null
#}

func _ready():
	server.listen(4523)
	readyItems()
	readyShelf()


func _process(_delta):
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
		#print(globals.hand_data)

		hand.move(x, y)
		hand.hover() if getting else hand.not_hovering()

func readyItems():
	items.shuffle()
	# change to a proper class later
	var textures : Array = []
	for txt in items:
		var item : Item = preload("res://scenes/item.tscn").instantiate()
		if item.get_node("Texture"):
			var item_texture = item.get_node("Texture")
			item_texture.texture = txt
		item.scale = Vector2(0.1, 0.1)
		textures.append(item)

	for i in range(10):
		$Items/Box_Items.get_children()[i].add_child(textures[i])
		print($Items/Box_Items.get_children()[i].get_child(0))

func readyShelf():
	items.shuffle()

	var slots : Array = []
	for txt in items:
		var slot : ShelfSlot = preload("res://scenes/shelf_slot.tscn").instantiate()
		if slot.get_node("Texture"):
			var slot_texture = slot.get_node("Texture")
			slot_texture.texture = txt

			slot.scale = Vector2(0.1, 0.1)
		slot.visible = false
		slots.append(slot)
	for i in range(9):
		$"Items/Shelf Items".get_children()[i].add_child(slots[i])
