import uuid

from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
import os

from job_queue import JobQueue

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

job_queue = JobQueue()

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

    job_queue.add_job(print, job_id)

    return JSONResponse(content={"job_id": job_id, "message": "Audio file uploaded successfully"})


@app.get('/jobstatus/{job_id}')
def get_job_status(job_id):
    status = job_queue.get_job_status(job_id)
    if status:
        return JSONResponse(status)
    return JSONResponse({"error": "Job not found"}), 403


@app.get("/echo/{message}")
async def echo(message: str):
    return {"message": message}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
