from fastapi import FastAPI
from fastapi.openapi.models import Response
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
import os

app = FastAPI()

if os.environ.get('IN_DOCKER') is not None:
    print('running in docker')
    static_dir = os.path.join(os.path.dirname(__file__), "static")
else:
    print('running in local machine')
    static_dir = os.path.join(os.path.dirname(__file__), "../client", "build", "web")

# Mount the static directory
app.mount("/static", StaticFiles(directory=static_dir), name="static")


# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

@app.get("/")
async def read_root():
    return FileResponse(os.path.join(static_dir, "index.html"))

@app.head("/")
async def uptime():
    return Response(headers={"X-Custom-Header": "Some Value"})

@app.get("/echo/{message}")
async def echo(message: str):
    return {"message": message}

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
