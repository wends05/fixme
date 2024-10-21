


# server_node.gd
class_name ServerNode
extends Node

var server := UDPServer.new()
@export var hand : Hand

func _ready():
	server.listen(4523)

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
		hand.position = Vector2(x, y - 80)
		hand.hover() if getting else hand.not_hovering()
