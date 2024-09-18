import librosa
import torch

save_directory = "complete/whisper-finetuned"

from transformers import pipeline, AutoModel, AutoTokenizer

model = AutoModel.from_pretrained(save_directory)
tokenizer = AutoTokenizer.from_pretrained(save_directory)

def process_audio(audio_path, sr=16000):
    # Load the audio file
    audio, sample_rate = librosa.load(audio_path, sr=sr)

    # If the audio is stereo, convert to mono
    if len(audio.shape) > 1:
        audio = librosa.to_mono(audio)

    return audio

device = "cuda:0" if torch.cuda.is_available() else "cpu"
pipe = pipeline(
    "automatic-speech-recognition",
    model="./complete/whisper-finetuned",
    chunk_length_s=30,
    device=device
)

result = pipe('dataset/Testing/174-50561-0010.flac')

print(f"Transcription: {result['text']}")

