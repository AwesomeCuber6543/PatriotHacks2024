import numpy as np
import mediapipe as mp
import math
import threading
from flask import Flask, jsonify, request
import os
import openai
import cv2 as cv
import multiprocessing
import speech_recognition as sr
import wave
import whisper
# import secretkey
import gtts
from playsound import playsound
from flask_cors import CORS
import time
import matplotlib.pyplot as plt
import matplotlib
import face_recognition
from keras.models import model_from_json
from keras.preprocessing.image import load_img
import faulthandler
faulthandler.enable()


matplotlib.use('Agg')

model = whisper.load_model('base')

# Constants for audio recording
FORMAT = sr.AudioData
CHANNELS = 1
RATE = 22000
RECORD_SECONDS = 45  

recognizer = sr.Recognizer()





mp_face_mesh = mp.solutions.face_mesh

app = Flask(__name__)
CORS(app)


interview_start_event = threading.Event()

eyePos = []
known_face_names = []
face_locations = []
face_encodings = []
face_names = []
known_face_encodings = []
history = []
keyWords = ['teamwork', "communication", "problem-solving", "adaptability", "leadership", "punctuality", "initiative", "detail-oriented", "collaboration", "creativity", "critical-thinking", "decision-making", "conflict-resolution", "customer-service", "multitasking", "echnical-skills", "organization", "Self-motivation", "flexibility", "goal-oriented", "learning", "networking", "Project-management", "customer-focus", "innovation", "analysis", "empathy", "work-ethic", "resourcefulness", "professionalism"]
keyWordsHit = []
fillerWordsUsed = 0
count = 0
interviewDone = False
questionsForInterview = 1

# openai.api_key = secretkey.SECRET_KEY
conversation = [{"role": "system", "content": "You are an interviewer for a company. You will ask behavioural questions similar to What is your biggest flaw or why do you want to work here. The first message you will say is Hello my name is Prepper and I will be your interviewer. Make sure to ask the questions one at a time and wait for the response. Make it seem like a natural conversation. Make sure the questions do not get too technical and if they do and you believe you cannot continue anymore say Alright and ask another behavioral question make sure you ask follow up questions based on the answers. MAKE SURE you also try and make it super casual, like you are my friend. Maybe even throw in a few jokes or something. After you believe the interview has gotten to a good ending point then you will say ONLY the phrase: ok then thank you so much for your time and have a nice day"}]

json_file = open("facialemotionmodel.json", "r")
# json_file = open("fer.json", "r")

model_json = json_file.read()
json_file.close()
model = model_from_json(model_json)

model.load_weights("facialemotionmodel.h5")
# model.load_weights("fer.h5")
haar_file=cv.data.haarcascades + 'haarcascade_frontalface_default.xml'
face_cascade=cv.CascadeClassifier(haar_file)






cap = cv.VideoCapture(1)

LEFT_IRIS = [474, 475, 476, 477]
RIGHT_IRIS = [469, 470, 471, 472]

L_H_LEFT = [33]     
L_H_RIGHT = [133]  
R_H_LEFT = [362]    
R_H_RIGHT = [263]  

def euclidean_distance(self, point1, point2):
    x1, y1 =point1.ravel()
    x2, y2 =point2.ravel()
    distance = math.sqrt((x2-x1)**2 + (y2-y1)**2)
    return distance

def iris_position(self, iris_center, right_point, left_point):
    # center_to_right_dist = euclidean_distance(iris_center, right_point)
    # total_distance = euclidean_distance(right_point, left_point)
    # ratio = center_to_right_dist/total_distance
    # iris_position =""
    # if ratio >= 2.2 and ratio <= 2.7:
    #     iris_position = "right"
    # elif ratio >= 2.95 and ratio <= 3.2:
    #     iris_position = "left"
    # else:
    #     iris_position = "center"
    # return iris_position, ratio
    return iris_center, right_point, left_point

def runFullIris():
    global interviewDone
    with mp_face_mesh.FaceMesh(max_num_faces=1, refine_landmarks=True, min_detection_confidence=0.5, min_tracking_confidence=0.5) as face_mesh:
        count = 0
        while True:
            if interviewDone:
                # gpt_thread.join()
                pass
            ret, frame = cap.read()
            if not ret:
                break
            frame = cv.flip(frame, 1)
            rgb_frame = cv.cvtColor(frame, cv.COLOR_BGR2RGB)  
            img_h, img_w = frame.shape[:2]
            results = face_mesh.process(rgb_frame)
            if results.multi_face_landmarks:
                mesh_points=np.array([np.multiply([p.x, p.y], [img_w, img_h]).astype(int) for p in results.multi_face_landmarks[0].landmark])

                (l_cx, l_cy), l_radius = cv.minEnclosingCircle(mesh_points[LEFT_IRIS])
                (r_cx,r_cy), r_radius = cv.minEnclosingCircle(mesh_points[RIGHT_IRIS])

                center_left = np.array([l_cx, l_cy], dtype=np.int32)
                center_right = np.array([r_cx, r_cy], dtype=np.int32)

                cv.circle(frame, center_left, int(l_radius), (122, 0, 255), 1, cv.LINE_AA)
                cv.circle(frame, center_right, int(r_radius), (122, 0, 255), 1, cv.LINE_AA)

                cv.circle(frame, mesh_points[R_H_RIGHT][0], 3, (0, 122, 255), -1, cv.LINE_AA)
                cv.circle(frame, mesh_points[R_H_LEFT][0], 3, (0, 122, 255), -1, cv.LINE_AA)

                # iris_pos, ratio = iris_position(center_right, mesh_points[R_H_RIGHT], mesh_points[R_H_LEFT][0])
                left_coordinates, right_coordinates = center_left, center_right

                # Store eye positions for plotting
                
                # print(iris_pos)
                # print(count)
                count += 1
            if count % 30 == 0 and count != 0:
                eyePos.append((left_coordinates, right_coordinates))
            cv.imshow("img", frame)
            key = cv.waitKey(1)
            if key ==ord("q"):
                x = calcPercentage(eyePos, "center")
                print("THE ACCURACY IS ", x , "%")
                print(keyWordsHit)
                break
    cap.release()
    cv.destroyAllWindows()

def calcPercentage(arr, target):
    num = 0
    if len(arr) > 0:
        for x in arr:
            if x == target:
                num += 1
        return (num/len(arr)) * 100
    else:
        return 0
    
def face_confidence(face_distance, face_match_threshold=0.6):
    range = (1.0 - face_match_threshold)
    linear_val = (1.0-face_distance)/(range*2.0)

    if face_distance > face_match_threshold:
        return str(round(linear_val * 100, 2)) + '%'
    else:
        value = (linear_val + ((1.0 - linear_val) * math.pow((linear_val - 0.5) * 2, 0.2))) * 100
        return str(round(value, 2)) + '%'
# def calculate_velocity(eye_positions, time_points):
#     # Calculate velocity of horizontal movement (change in x-coordinates over time)
#     velocities = []
#     for i in range(1, len(eye_positions)):
#         left_eye_x_prev = eye_positions[i-1][0][0]  # Previous left eye x
#         right_eye_x_prev = eye_positions[i-1][1][0]  # Previous right eye x

#         left_eye_x_current = eye_positions[i][0][0]  # Current left eye x
#         right_eye_x_current = eye_positions[i][1][0]  # Current right eye x

#         # Calculate velocity (change in position / change in time)
#         delta_time = time_points[i] - time_points[i-1]
#         left_eye_velocity = (left_eye_x_current - left_eye_x_prev) / delta_time
#         right_eye_velocity = (right_eye_x_current - right_eye_x_prev) / delta_time
        
#         velocities.append((left_eye_velocity, right_eye_velocity))

#     return velocities

def calculate_velocity(eye_positions, time_points):
    velocities = []
    for i in range(1, len(eye_positions) - 1):
        delta_time = time_points[i + 1] - time_points[i - 1]
        left_eye_velocity = (eye_positions[i + 1][0][0] - eye_positions[i - 1][0][0]) / delta_time
        right_eye_velocity = (eye_positions[i + 1][1][0] - eye_positions[i - 1][1][0]) / delta_time
        velocities.append((left_eye_velocity, right_eye_velocity))
    return velocities



# def plot_velocities(velocities, time_points):
#     # Split velocities into left and right eye velocities
#     left_eye_velocities = [v[0] for v in velocities]
#     right_eye_velocities = [v[1] for v in velocities]

#     # Create the plot
#     plt.figure(figsize=(10, 5))
    
#     # Plot left eye velocities
#     plt.plot(time_points[1:], left_eye_velocities, color='blue', label='Left Eye Velocity', marker='o', linestyle='-')
    
#     # Plot right eye velocities
#     plt.plot(time_points[1:], right_eye_velocities, color='red', label='Right Eye Velocity', marker='o', linestyle='-')
    
#     # Adding labels and title
#     plt.xlabel('Time (seconds)')
#     plt.ylabel('Velocity (pixels/second)')
#     plt.title('Left and Right Eye Velocities Over Time')
    
#     # Adding a legend
#     plt.legend()

#     # Display the plot
#     plt.tight_layout()
#     plt.savefig("./static/velocities_test")
#     plt.close()

def plot_velocities(velocities, time_points):
    # Split velocities into left and right eye velocities
    left_eye_velocities = [v[0] for v in velocities]
    right_eye_velocities = [v[1] for v in velocities]

    # Use time_points[1:-1] to match the length of velocities
    time_for_velocities = time_points[1:-1]

    # Create the plot
    plt.figure(figsize=(10, 5))
    
    # Plot left eye velocities
    plt.plot(time_for_velocities, left_eye_velocities, color='blue', label='Left Eye Velocity', marker='o', linestyle='-')
    
    # Plot right eye velocities
    plt.plot(time_for_velocities, right_eye_velocities, color='red', label='Right Eye Velocity', marker='o', linestyle='-')
    
    # Adding labels and title
    plt.xlabel('Time (seconds)')
    plt.ylabel('Velocity (pixels/second)')
    plt.title('Left and Right Eye Velocities Over Time')
    
    # Adding a legend
    plt.legend()

    # Display the plot
    plt.tight_layout()
    plt.savefig("./static/velocities_test_dizzy")
    plt.close()

def smooth_velocities(velocities, window_size=5):
    smoothed_velocities = []
    for i in range(len(velocities)):
        start = max(0, i - window_size // 2)
        end = min(len(velocities), i + window_size // 2 + 1)
        window = velocities[start:end]
        avg_left_vel = np.mean([v[0] for v in window])
        avg_right_vel = np.mean([v[1] for v in window])
        smoothed_velocities.append((avg_left_vel, avg_right_vel))
    return smoothed_velocities


def detect_nystagmus(velocities, threshold=50):
    nystagmus_detected = False
    jerky_movements = 0

    for left_vel, right_vel in velocities:
        if abs(left_vel) > threshold or abs(right_vel) > threshold:
            jerky_movements += 1
        else:
            jerky_movements = 0  # Reset count if no jerky movement

        if jerky_movements > 3:  # If more than 3 consecutive jerky movements are detected
            nystagmus_detected = True
            break

    return nystagmus_detected

def extract_features(image):
    feature = np.array(image)
    feature = feature.reshape(1,48,48,1)
    return feature/255.0


def encode_faces():
    for image in os.listdir('assets'):
        face_image = face_recognition.load_image_file(f'assets/{image}')
        face_encoding = face_recognition.face_encodings(face_image)[0]

        known_face_encodings.append(face_encoding)
        known_face_names.append(image)
        name = image.split(".")[0]
        # students[f'{name}'] = {'presence':'absent', 'wasPresent':False, 'timeGone':0, 'Warning': False, 'emotion':'neutral'}
        # print(self.known_face_names)

# def runIris():
#     ir = iris_recognition()
#     ir.runFullIris()

# def runGPT():
#     gpt = chattingWork()
#     gpt.runConvo()




@app.route('/GetContactPercentage', methods = ['POST', 'GET'])
def getContactPercentage():
    try:
        return jsonify(float(round(calcPercentage(eyePos, "center"), 2))), 200
    except:
        return jsonify({'message': 'There was a problem getting the eye contact accuracy'}), 400
    

@app.route('/getKeyWordUsage', methods = ['GET'])
def getKeyWordUsage():
    try:

        return jsonify(keyWordsHit), 200
    except:
        return jsonify({'message': 'There was a problem getting the key words used'}), 400
    

@app.route('/getFillerWordsUsed', methods = ['GET'])
def getFillerWordUsage():
    try:

        return jsonify(fillerWordsUsed), 200
    except:
        return jsonify({'message': 'There was a problem getting the number of filler words used'}), 400



    
@app.route('/StartInterview', methods=['POST', 'GET'])
def startInterview():
    global conversation
    global count
    try:
        eyePos.clear()
        keyWordsHit.clear()
        conversation = [{"role": "system", "content": "You are an interviewer for a company. ..."}]
        count = 0
        interview_start_event.set()  # Set the event to start the interview
        print("Interview started")
        return jsonify({'message': 'Interview was started'}), 200
    except:
        return jsonify({'message': 'There was a problem starting the interview'}), 400
    
@app.route('/EndInterview', methods=['POST', 'GET'])
def endInterview():
    global interviewDone
    try:
        interviewDone = True
        return jsonify({'message': 'Interview was ended'}), 200
    except:
        return jsonify({'message': 'There was a problem ending the interview'}), 400

@app.route('/isInterviewDone', methods = ['POST', 'GET'])
def isInterviewDone():
    try:
        jsonify({'message': interviewDone}), 200
    except:
        return jsonify({'message': 'There was a problem getting the status of the interview'}), 400

    
@app.route('/start_test', methods=['POST'])
def start_test():
    # try:
    print("STARTING")
    # Clear previous eye position data
    eyePos.clear()
    
    # Initialize face mesh for iris tracking
    with mp_face_mesh.FaceMesh(max_num_faces=1, refine_landmarks=True, min_detection_confidence=0.5, min_tracking_confidence=0.5) as face_mesh:
        start_time = time.time()
        time_points = []
        while time.time() - start_time < 10:
            # print("current Time is", time.time())
            # print("start time is", start_time)
            ret, frame = cap.read()
            if not ret:
                break
            frame = cv.flip(frame, 1)
            rgb_frame = cv.cvtColor(frame, cv.COLOR_BGR2RGB)
            img_h, img_w = frame.shape[:2]
            results = face_mesh.process(rgb_frame)

            if results.multi_face_landmarks:
                # print("HERE")
                mesh_points = np.array([np.multiply([p.x, p.y], [img_w, img_h]).astype(int) for p in results.multi_face_landmarks[0].landmark])

                # Get the iris coordinates
                (l_cx, l_cy), l_radius = cv.minEnclosingCircle(mesh_points[LEFT_IRIS])
                (r_cx, r_cy), r_radius = cv.minEnclosingCircle(mesh_points[RIGHT_IRIS])

                center_left = np.array([l_cx, l_cy], dtype=np.int32)
                center_right = np.array([r_cx, r_cy], dtype=np.int32)

                # Capture the coordinates of the left and right iris
                left_coordinates, right_coordinates = center_left, center_right

                # Store eye positions for plotting
                eyePos.append((left_coordinates, right_coordinates))
                time_points.append(time.time() - start_time)
                # Visualize the eye position on the frame
                cv.circle(frame, center_left, int(l_radius), (255, 0, 255), 1, cv.LINE_AA)
                cv.circle(frame, center_right, int(r_radius), (255, 0, 255), 1, cv.LINE_AA)

                # cv.imshow("Eye Tracking", frame)
            
            if cv.waitKey(1) & 0xFF == ord('q'):
                break
        # Calculate velocities for detecting jerky movements
        velocities = calculate_velocity(eyePos, time_points)

        # Detect if nystagmus is present
        # nystagmus_present = detect_nystagmus(velocities)
        # smoothed_velocities = smooth_velocities(velocities, window_size=5)

        # Plot smoothed velocities
        plot_velocities(velocities, time_points)
        # print("EYE POS DIZZY HADEEL: ", eyePos)


    # Generate and save the graph
    plt.figure(figsize=(10, 5))
    time_points = [i for i in range(len(eyePos))]
    left_eye_x = [pos[0][0] for pos in eyePos]
    left_eye_y = [pos[0][1] for pos in eyePos]
    right_eye_x = [pos[1][0] for pos in eyePos]
    right_eye_y = [pos[1][1] for pos in eyePos]

    plt.plot(time_points, left_eye_x, marker='o', linestyle='-', color='b', label='Left Eye X')
    plt.plot(time_points, left_eye_y, marker='o', linestyle='-', color='r', label='Left Eye Y')
    plt.plot(time_points, right_eye_x, marker='o', linestyle='-', color='g', label='Right Eye X')
    plt.plot(time_points, right_eye_y, marker='o', linestyle='-', color='y', label='Right Eye Y')
    
    plt.xlabel('Time (frames)')
    plt.ylabel('Eye Coordinates')
    plt.title('Eye Movement Over Time')
    plt.legend()
    plt.xticks(rotation=45)
    plt.tight_layout()

    # Save the graph as an image
    output_path = './static/eye_position_graph_1_dizzy_hadeel.png'
    plt.savefig(output_path)
    plt.close()

    # Return the path to the graph for visualization
    return jsonify({'message': 'Test completed', 'graph': output_path}), 200
    
    # except Exception as e:
    #     return jsonify({'message': 'Error occurred during eye test', 'error': str(e)}), 400

@app.route('/check_face', methods=['POST'])
def check_face():

    data = request.get_json()
    name_checked = data.get('name_checked')

    while True:
        print("HI")
        ret, frame = cap.read()
        #print("shafty", ret)
        
        small_frame = cv.resize(frame, (0,0), fx=0.25, fy=0.25)
        rgb_small_frame = small_frame[:, :, ::-1]

        face_locations = face_recognition.face_locations(rgb_small_frame)
        face_encodings = face_recognition.face_encodings(rgb_small_frame, face_locations)

        temp_students_present = []
        face_names = []
        for face_encoding in face_encodings:
            matches = face_recognition.compare_faces(known_face_encodings, face_encoding)
            name = 'Unknown'
            confidence = 'Unknown'

            face_distances = face_recognition.face_distance(known_face_encodings, face_encoding)
            best_match_index = np.argmin(face_distances)

            if matches[best_match_index]:
                # print(matches[best_match_index])
                #print(students_present.keys())
                name = known_face_names[best_match_index]
                #print(name)
                confidence = face_confidence(face_distances[best_match_index])
                print("NAME IS", name.split('.')[0], "WITH CONFIDENCE", confidence)
            face_names.append(f'{name.split(".")[0]} ({confidence})')
            if(name.split('.')[0] == f'{name_checked}'):
                return jsonify({'message': 'Test completed', 'Passed': True}), 200
            elif(name == 'Unknown'):
                continue
            else:
                print("FINAL NAME IS", name.split('.')[0], "AND CHECKED NAME IS", name_checked)
                return jsonify({'message': 'Test completed', 'Passed': False}), 200


@app.route('/start_drive', methods=['POST'])
def start_drive():

    data = request.get_json()
    name_checked = data.get('name_checked')

    while True:
        print("HI")
        ret, frame = cap.read()
        #print("shafty", ret)
        
        small_frame = cv.resize(frame, (0,0), fx=0.25, fy=0.25)
        rgb_small_frame = small_frame[:, :, ::-1]

        face_locations = face_recognition.face_locations(rgb_small_frame)
        face_encodings = face_recognition.face_encodings(rgb_small_frame, face_locations)

        temp_students_present = []
        face_names = []
        for face_encoding in face_encodings:
            matches = face_recognition.compare_faces(known_face_encodings, face_encoding)
            name = 'Unknown'
            confidence = 'Unknown'

            face_distances = face_recognition.face_distance(known_face_encodings, face_encoding)
            best_match_index = np.argmin(face_distances)

            if matches[best_match_index]:
                # print(matches[best_match_index])
                #print(students_present.keys())
                name = known_face_names[best_match_index]
                #print(name)
                confidence = face_confidence(face_distances[best_match_index])
                print("NAME IS", name.split('.')[0], "WITH CONFIDENCE", confidence)
            face_names.append(f'{name.split(".")[0]} ({confidence})')
            if(name.split('.')[0] == f'{name_checked}' or name.split('.')[0] == 'Unknown'):
                continue
            else:
                print("FINAL NAME IS", name.split('.')[0], "AND CHECKED NAME IS", name_checked)
                return jsonify({'message': 'Test completed', 'Passed': False}), 200

if __name__ == "__main__":
    encode_faces()
    # runFullIris()
    app.run()