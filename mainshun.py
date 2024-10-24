import cv2
import numpy as np
import mediapipe as mp
import socket
import json
# Mediapipe hands module
mp_hands = mp.solutions.hands
hands = mp_hands.Hands()

# Define the shapes and their colors
shapes = {
    "circle": (255, 0, 0), 
    "rectangle": (0, 255, 0),  
    "triangle": (0, 0, 255)  
}

# Initial position for the shapes
circle_position = (100, 100)
rectangle_position = (300, 100)
triangle_position = np.array([[400, 200], [350, 300], [450, 300]], np.int32)

# Mouse state
dragging = False
current_shape = None

# UDP Server
server_ip = "127.0.0.1"
server_port = 4523
serverSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

def is_point_in_shape(point, shape):
    if shape == "circle":
        return cv2.norm((point[0] - circle_position[0], point[1] - circle_position[1])) <= 50
    elif shape == "rectangle":
        return rectangle_position[0] <= point[0] <= rectangle_position[0] + 100 and rectangle_position[1] <= point[1] <= rectangle_position[1] + 100
    elif shape == "triangle":
        return cv2.pointPolygonTest(triangle_position, point, False) >= 0
    return False

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
    cv2.circle(temp_frame, circle_position, 50, shapes["circle"], -1)
    cv2.rectangle(temp_frame, rectangle_position, (rectangle_position[0] + 100, rectangle_position[1] + 100), shapes["rectangle"], -1)
    cv2.fillPoly(temp_frame, [triangle_position], shapes["triangle"])

    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            # Get the coordinates of the index and middle finger tips
            index_finger_tip = hand_landmarks.landmark[mp_hands.HandLandmark.INDEX_FINGER_TIP]
            middle_finger_tip = hand_landmarks.landmark[mp_hands.HandLandmark.MIDDLE_FINGER_TIP]
            finger_x = int(index_finger_tip.x * desired_width)
            finger_y = int(index_finger_tip.y * desired_height)
            middle_x = int(middle_finger_tip.x * desired_width)
            middle_y = int(middle_finger_tip.y * desired_height)


            # Draw circles at the fingertip positions
            cv2.circle(frame, (finger_x, finger_y), 0, (0, 255, 0), -1)
            cv2.circle(frame, (middle_x, middle_y), 0, (0, 0, 255), -1)

            # Calculate the distance between the index and middle finger tips
            distance = cv2.norm((finger_x - middle_x, finger_y - middle_y))

            # Check if the hand is closed 
            hand_closed = distance < 50  

            # Check if the fingertip is over any shape
            if hand_closed:
                if is_point_in_shape((finger_x, finger_y), "circle"):
                    current_shape = "circle"
                elif is_point_in_shape((finger_x, finger_y), "rectangle"):
                    current_shape = "rectangle"
                elif is_point_in_shape((finger_x, finger_y), "triangle"):
                    current_shape = "triangle"

                if current_shape:
                    dragging = True  # Start dragging
                    if current_shape == "circle":
                        circle_position = (finger_x, finger_y)
                    elif current_shape == "rectangle":
                        rectangle_position = (finger_x - 50, finger_y - 50)  # Center the rectangle
                    elif current_shape == "triangle":
                        triangle_position = np.array([[finger_x, finger_y], [finger_x - 50, finger_y + 100], [finger_x + 50, finger_y + 100]], np.int32)
            else:
                if dragging:
                    # Drop the shape when the hand is opened
                    dragging = False
                    current_shape = None

        # If no hands are detected, stop dragging
        if not results.multi_hand_landmarks:
            dragging = False
            current_shape = None
        
        if hand_closed:
            data = {
                "getting": True,
                "position": f"{round(index_finger_tip.x, 5)}, {round(index_finger_tip.y, 5)}"
            }
        else:
            data = {
                "getting": False,
                "position": f"{round(index_finger_tip.x, 5)}, {round(index_finger_tip.y)}"
            }
        serverSocket.sendto(json.dumps(data).encode('ascii'), (server_ip, server_port))

    cv2.imshow("Hand Tracker", temp_frame)

    if cv2.waitKey(1) & 0xFF == 27:  # Esc to exit
        break

cap.release()
cv2.destroyAllWindows()
