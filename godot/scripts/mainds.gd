class_name Game
extends Node2D


#var items: Array[Resource] = [biscoff, c2, cheetos, doritos, mayo, milk, oreo, spam, tinapay, some_item]

var server := UDPServer.new()

@export var items: Array[CompressedTexture2D]
@export var hand: Hand
@export var UI: UI

@export var item_scale: Vector2

@export var shelf_item_scale: Vector2

@onready var game_timer = $Timer
var timer_ended = false


func _ready():
	globals.score = 0
	globals.win = false
	globals.time_left = 240

	server.listen(4523)
	readyItems()
	readyShelfandGuide()

	globals.scoreIncreased.connect(checkScore)
	game_timer.timeout.connect(end_game)

func checkScore():
	if globals.score == 9:
		game_timer.paused = true
		globals.time_left = game_timer.time_left
		globals.win = true
		end_game()


func end_game():
	timer_ended = true
	await UI.closeDoors()
	get_tree().change_scene_to_file("res://scenes/endgame.tscn")


func _process(_delta):

	if timer_ended: return

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
		hand.close() if getting else hand.open()

func readyItems():
	items.shuffle()
	# change to a proper class later
	var textures: Array = []
	for txt in items:
		var item: Item = preload("res://scenes/items/item.tscn").instantiate()
		item.ui = UI
		if item.get_node("Texture"):
			var item_texture = item.get_node("Texture")
			item_texture.texture = txt
		item.scale = item_scale
		textures.append(item)

	for i in range(10):
		$Items/Box_Items.get_children()[i].add_child(textures[i])

func readyShelfandGuide():
	items.shuffle()

	var slots: Array = []
	for txt in items:
		var slot: ShelfSlot = preload("res://scenes/items/shelf_slot.tscn").instantiate()
		slot.slot_texture = txt

		var s_Texture: TextureRect = slot.get_node("Texture")

		if s_Texture:
			s_Texture.texture = txt
			s_Texture.visible = false
			s_Texture.scale = shelf_item_scale

		slots.append(slot)
	for i in range(9):
		$"Items/Shelf Items".get_children()[i].add_child(slots[i])
		UI.GuideSheet.get_children()[i].texture = items[i]
