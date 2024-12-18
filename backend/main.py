import pickle
import uuid

import librosa
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
import os
from job_queue import JobQueue, Job
import torch
from transformers import pipeline, AutoModel, AutoTokenizer
import python_speech_features as mfcc
from sklearn import preprocessing
import numpy as np

#################################################################################################
# transcription setup
save_directory = "model"
model = AutoModel.from_pretrained(save_directory)
tokenizer = AutoTokenizer.from_pretrained(save_directory)

device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")
print('Model is using', device)
pipe = pipeline(
    "automatic-speech-recognition",
    model="./model",
    chunk_length_s=30,
    device=device
)


def run_transcription(job: Job):
    return pipe(job.audio_path)['text']

#################################################################################################
# voice gender setup
gmm_male = pickle.load(open('voice_model/male.gmm','rb'))
gmm_female = pickle.load(open('voice_model/female.gmm','rb'))

def get_MFCC(sr, audio):
    features = mfcc.mfcc(audio, sr, 0.025, 0.01, 13, appendEnergy=False)
    features = preprocessing.scale(features)
    return features

def run_gender_analysis(job: Job):
    audio, sample_rate = librosa.load(job.audio_path, res_type='soxr_vhq')
    features = get_MFCC(sample_rate, audio)

    log_likelihood_male = np.array(gmm_male.score(features)).sum()
    log_likelihood_female = np.array(gmm_female.score(features)).sum()

    if log_likelihood_male >= log_likelihood_female:
        return "Male"
    else:
        return "Female"


#################################################################################################

app = FastAPI()

if os.environ.get('IN_DOCKER') is not None:
    print('running in docker')
    static_dir = os.path.join(os.path.dirname(__file__), "static")
else:
    print('running in local machine')
    static_dir = os.path.join(os.path.dirname(__file__), "../client", "build", "web")

UPLOAD_DIR = "uploads"

if not os.path.exists(UPLOAD_DIR):
    os.makedirs(UPLOAD_DIR)

#################################################################################################
# end points setup
# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

transcription_queue = JobQueue()
gender_queue = JobQueue()

# Mount the static directory
app.mount("/static", StaticFiles(directory=static_dir), name="static")


@app.api_route('/', methods=['GET', 'HEAD'])
async def read_root():
    return FileResponse(os.path.join(static_dir, "index.html"))


@app.post("/upload")
async def upload_audio(audio_file: UploadFile = File(...)):
    job_id = str(uuid.uuid4())

    # Get the file extension
    file_name, file_extension = os.path.splitext(audio_file.filename)

    # Create a unique filename
    filename = f"{file_name}_{job_id}{file_extension}"
    file_path = os.path.join(UPLOAD_DIR, filename)

    # Save the file
    with open(file_path, "wb") as buffer:
        content = await audio_file.read()
        buffer.write(content)

    gender_queue.add_job(run_gender_analysis, job_id, file_path)
    transcription_queue.add_job(run_transcription, job_id, file_path)

    return JSONResponse(content={"job_id": job_id, "message": "Audio file uploaded successfully"})


@app.get('/transcription/{job_id}')
def get_job_status(job_id):
    status = transcription_queue.get_job_status(job_id)
    if status:
        return JSONResponse(status)
    return JSONResponse({"error": "Job not found"}), 403


@app.get('/gender/{job_id}')
def get_job_status(job_id):
    status = gender_queue.get_job_status(job_id)
    if status:
        return JSONResponse(status)
    return JSONResponse({"error": "Job not found"}), 403


@app.get("/echo/{message}")
async def echo(message: str):
    return {"message": message}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
