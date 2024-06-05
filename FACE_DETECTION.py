import cv2

cap = cv2.VideoCapture(0)
trackers = cv2.legacy.MultiTracker_create()
prev_faces = 0

while True:

    _, frame = cap.read()

    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
    faces = face_cascade.detectMultiScale(cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY), scaleFactor = 1.1, minNeighbors = 5)

    if len(faces) != prev_faces:
        prev_faces = len(faces)
        trackers = cv2.legacy.MultiTracker_create()
        for i in range(0, len(faces)):
            tracker = cv2.legacy.TrackerKCF_create()
            box = (faces[i][0], faces[i][1], faces[i][2], faces[i][3])
            trackers.add(tracker, frame, box)

    _, boxes = trackers.update(frame)
    for box in boxes:
        (x, y, w, h) = [int(v) for v in box]
        cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 0, 255), 2)

    cv2.imshow('Frame', frame)

    key = cv2.waitKey(1) & 0xFF
    if key == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()