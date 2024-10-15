import socket

serverSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
serverSocket.sendto(b"hello", ("127.0.0.1", 4523))