extends Node

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 2
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost

var server = null
var client = null

var ip_address = ""
var client_connected_to_server = false

@onready var client_connection_timeout_timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(client_connection_timeout_timer)
	client_connection_timeout_timer.wait_time = 10
	client_connection_timeout_timer.one_shot = true
	client_connection_timeout_timer.timeout.connect(_client_connection_timeout)
	
	# set IP for hosting by OS type
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
		print(ip_address)
	elif OS.get_name() == "Android":
		ip_address = IP.get_local_addresses()[0]
	else:
		ip_address = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			ip_address = ip
	
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.server_disconnected.connect(_server_disconnected)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func create_server():
	server = ENetMultiplayerPeer.new()
	var error = server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	if error:
		return error
	multiplayer.multiplayer_peer = server
	
func join_server(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	client = ENetMultiplayerPeer.new()
	var error = client.create_client(ip_address, DEFAULT_PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = client
	client_connection_timeout_timer.start()

func _connected_to_server() -> void:
	print("Successfully connected to the server")
	client_connected_to_server = true

func _server_disconnected() -> void:
	# Server kicked us; show error and abort.
	print("Disconnected from the server")

func _client_connection_timeout():
	if client_connected_to_server == false:
		print("Client has been timed out")
		reset_network_connection()
		
func _connection_failed():
	# Could not even connect to server; abort.
	reset_network_connection()

func reset_network_connection() -> void:
	multiplayer.multiplayer_peer = null

func _on_player_connected(id: int):
	print("Player conected")
	print(id)

func _on_player_disconnected(id: int):
	print("Player disconected")
	print(id)
