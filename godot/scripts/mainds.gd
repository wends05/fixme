


# server_node.gd
class_name GameDS
extends Node

var server := UDPServer.new()
@export var hand : Hand

var final_items = {
	0: null
}

func _ready():
	server.listen(4523)
	readyItems()


func _process(_delta):
	server.poll() # Important!
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		var packet = peer.get_packet()
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		print("Received data: %s" % [packet.get_string_from_utf8()])

		var data : String = JSON.parse_string(packet.get_string_from_utf8()).position
		var getting = JSON.parse_string(packet.get_string_from_utf8()).getting
		var x = data.split(",")[0].to_float() * get_window().size.x
		var y = data.split(",")[1].to_float() * get_window().size.y

		print(x, " ", y)
		hand.move(x, y)
		hand.hover() if getting else hand.not_hovering()

func readyItems():
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
	items.shuffle()

	# change to a proper class later
	var textures : Array[TextureRect] = []
	for i : Resource in items:
		var new_texture = TextureRect.new()
		new_texture.texture = i
		new_texture.scale = Vector2(0.1, 0.1)

		print(new_texture.texture)
		textures.append(new_texture)

	for i in range(10):
		$Items/Box_Items.get_children()[i].add_child(textures[i])
		print($Items/Box_Items.get_children()[i].get_child(0))
