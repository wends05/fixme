import cv2
import numpy as np
import mediapipe as mp
import socket
import json
# Mediapipe hands module
mp_hands = mp.solutions.hands
hands = mp_hands.Hands()

# Mouse state
dragging = False
current_shape = None

# UDP Server
server_ip = "127.0.0.1"
server_port = 4523
serverSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

cap = cv2.VideoCapture(2)

# Set the desired width and height
desired_width = 640
desired_height = 480

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    frame = cv2.flip(frame, 1)

    # Resize the frame to the desired dimensions
    frame = cv2.resize(frame, (desired_width, desired_height))

    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = hands.process(rgb_frame)

    temp_frame = frame.copy()

    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            # Get the coordinates of the index and middle finger tips
            thumb_tip = hand_landmarks.landmark[mp_hands.HandLandmark.THUMB_TIP]
            middle_finger_pip = hand_landmarks.landmark[mp_hands.HandLandmark.MIDDLE_FINGER_PIP]

            hand_placement = hand_landmarks.landmark[mp_hands.HandLandmark.WRIST]
            thumb_x = int(thumb_tip.x * desired_width)
            thumb_y = int(thumb_tip.y * desired_height)
            middle_x = int(middle_finger_pip.x * desired_width)
            middle_y = int(middle_finger_pip.y * desired_height)


            # Calculate the distance between the index and middle finger tips
            distance = cv2.norm((thumb_x - middle_x, thumb_y - middle_y))

            # Check if the hand is closed 
            hand_closed = distance < 50 


        # If no hands are detected, stop dragging
        if not results.multi_hand_landmarks:
            dragging = False
            current_shape = None
        
        if hand_closed:
            data = {
                "getting": True,
                "position": f"{round(hand_placement.x, 5)}, {round(hand_placement.y, 5) }"
            }
        else:
            data = {
                "getting": False,
                "position": f"{round(hand_placement.x, 5)}, {round(hand_placement.y, 5)}"
            }
        serverSocket.sendto(json.dumps(data).encode('ascii'), (server_ip, server_port))

    cv2.imshow("Hand Tracker", temp_frame)

    if cv2.waitKey(1) & 0xFF == 27:  # Esc to exit
        break

cap.release()
cv2.destroyAllWindows()
