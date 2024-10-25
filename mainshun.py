import cv2
import numpy as np
import mediapipe as mp
import socket
import json

# Mediapipe hands module
mp_hands = mp.solutions.hands
hands = mp_hands.Hands()

# UDP Server
server_ip = "127.0.0.1"
server_port = 4523
serverSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

cap = cv2.VideoCapture(0)

# Set the desired width and height
desired_width = 640
desired_height = 480

# Initialize variables for smoothing
smooth_factor = 0.2
last_hand_position = None

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    frame = cv2.flip(frame, 1)

    # Resize the frame to the desired dimensions
    frame = cv2.resize(frame, (desired_width, desired_height))

    # Convert the frame to grayscale
    gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    # Convert the grayscale frame back to RGB for Mediapipe processing
    rgb_frame = cv2.cvtColor(gray_frame, cv2.COLOR_GRAY2RGB)

    results = hands.process(rgb_frame)

    # Copy frame for the landmarks
    temp_frame = gray_frame.copy()

    if results.multi_hand_landmarks:
        # Only consider the first detected hand
        hand_landmarks = results.multi_hand_landmarks[0]

        for landmark in hand_landmarks.landmark:
            x = int(landmark.x * desired_width)
            y = int(landmark.y * desired_height)
            cv2.circle(temp_frame, (x, y), 5, 0, -1)  # Draw circle at each landmark in black

        # Get the coordinates of the thumb tip and middle finger pip
        thumb_tip = hand_landmarks.landmark[mp_hands.HandLandmark.THUMB_TIP]
        middle_finger_pip = hand_landmarks.landmark[mp_hands.HandLandmark.MIDDLE_FINGER_PIP]

        hand_placement = hand_landmarks.landmark[mp_hands.HandLandmark.WRIST]
        thumb_x = int(thumb_tip.x * desired_width)
        thumb_y = int(thumb_tip.y * desired_height)
        middle_x = int(middle_finger_pip.x * desired_width)
        middle_y = int(middle_finger_pip.y * desired_height)

        # Smooth the hand position
        if last_hand_position is None:
            last_hand_position = (hand_placement.x, hand_placement.y)
        else:
            last_hand_position = (
                smooth_factor * last_hand_position[0] + (1 - smooth_factor) * hand_placement.x,
                smooth_factor * last_hand_position[1] + (1 - smooth_factor) * hand_placement.y
            )

        # Calculate the distance between the thumb tip and middle finger pip
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
                "position": f"{round(last_hand_position[0], 5)}, {round(last_hand_position[1], 5)}"
            }
        else:
            data = {
                "getting": False,
                "position": f"{round(last_hand_position[0], 5)}, {round(last_hand_position[1], 5)}"
            }
        serverSocket.sendto(json.dumps(data).encode('ascii'), (server_ip, server_port))

    # Display the grayscale frame with hand landmarks
    cv2.imshow("Hand Tracker (Grayscale)", temp_frame)

    if cv2.waitKey(1) & 0xFF == 27:  # Esc to exit
        break

cap.release()
cv2.destroyAllWindows()