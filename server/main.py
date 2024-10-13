
import socket

import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision

import cv2 as cv

model_path = "./gesture_recognizer.task"

base_options = mp.tasks.BaseOptions(model_asset_path=model_path)
GestureRecognizer = mp.tasks.vision.GestureRecognizer
GestureRecognizerOptions = mp.tasks.vision.GestureRecognizerOptions
VisionRunningMode = mp.tasks.vision.RunningMode


options = GestureRecognizerOptions(
  base_options=base_options,
  running_mode=VisionRunningMode.IMAGE
)
recognizer =  GestureRecognizer.create_from_options(options)

cam = cv.VideoCapture(1)
frame_rate = cam.get(cv.CAP_PROP_FPS)

print("ajshkajskd")
# print(recognizer)

while cam.isOpened():
  success, frame = cam.read()

  if not success:
    print("No video")
    continue

  # frame = cv.cvtColor(frame, cv.COLOR_RGB2BGR)
  cv.imshow("Show Video", frame)

  # frame_rgb = cv.cvtColor(frame, cv.COLOR_RGB2GRAY)

  mp_image = mp.Image(
    image_format=mp.ImageFormat.SRGB,
    data=frame)
  
  # timestamp = cam.get(cv.CAP_PROP_POS_MSEC) / 1000

  res = recognizer.recognize(mp_image)

  if (len(res.gestures) > 0):
    print(res.gestures[0][0].category_name)
    print(res.hand_world_landmarks[0][5].x, " ", res.hand_world_landmarks[0][0].y)

  if cv.waitKey(1) == ord('q'):
    break

cam.release()
cv.destroyAllWindows()


# def run_server(server_ip: str, port: int):
#   client = socket

# if __name__ == "__main__":
#   pass