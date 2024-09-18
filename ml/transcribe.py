# %%
# load dataset
import os

import torch

device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")
print('device is', device)

transcripts = {}

with open('dataset/transcripts.txt', 'r') as file:
    for line in file:
        filename, transcription = line.split(' ', maxsplit=1)
        transcripts[filename] = transcription.strip()

training_dataset = {}
testing_dataset = {}

# filter training and testing dataset
folder_path = 'dataset/Testing'

testing = os.listdir(folder_path)

from datasets import Audio, Dataset

for filename in testing:
    name, extension = os.path.splitext(filename)
    transcript = transcripts[name]
    testing_dataset[name] = transcript
    transcripts.pop(name)

training_dataset = transcripts

assert len(os.listdir('dataset/Training')) == len(training_dataset)
assert len(os.listdir('dataset/Testing')) == len(testing_dataset)


# %%
# Convert to dataset
def convert_dataset(audio_dir, dataset_dict):
    filenames = list(dataset_dict.keys())
    scripts = list(dataset_dict.values())

    audio_paths = [f'{audio_dir}/{filen}.flac' for filen in filenames]
    dataset = Dataset.from_dict({
        "audio": audio_paths,
        "transcript": scripts,
        "filename": filenames
    })

    # Cast the audio column to Audio() type
    dataset = dataset.cast_column("audio", Audio(sampling_rate=16000))
    return dataset


training_dataset = convert_dataset('dataset/Training', training_dataset)
testing_dataset = convert_dataset('dataset/Testing', testing_dataset)

# print(training_dataset["audio"][0]['path'])
# print()
# %%
from transformers import WhisperTokenizer, WhisperFeatureExtractor

base_model = "openai/whisper-medium"

feature_extractor = WhisperFeatureExtractor.from_pretrained(base_model)

tokenizer = WhisperTokenizer.from_pretrained(base_model, language="English", task="transcribe")


def prepare_dataset(batch):
    # load and resample audio data from 48 to 16kHz
    audio = batch["audio"]

    # compute log-Mel input features from input audio array
    batch["input_features"] = feature_extractor(audio["array"], sampling_rate=audio["sampling_rate"]).input_features[0]

    # encode target text to label ids
    batch["labels"] = tokenizer(batch["transcript"]).input_ids
    return batch


training_dataset = training_dataset.map(prepare_dataset, num_proc=1)
testing_dataset = testing_dataset.map(prepare_dataset, num_proc=1)
print('complete mapping')

# %%
from transformers import WhisperProcessor, WhisperForConditionalGeneration

import torch

from dataclasses import dataclass
from typing import Any, Dict, List, Union


class DataCollatorSpeechSeq2SeqWithPadding:
    processor: Any
    decoder_start_token_id: int

    def __init__(self, processor, decoder_start_token_id):
        self.processor = processor
        self.decoder_start_token_id = decoder_start_token_id

    def __call__(self, features: List[Dict[str, Union[List[int], torch.Tensor]]]) -> Dict[str, torch.Tensor]:
        # split inputs and labels since they have to be of different lengths and need different padding methods
        # first treat the audio inputs by simply returning torch tensors
        input_features = [{"input_features": feature["input_features"]} for feature in features]
        batch = self.processor.feature_extractor.pad(input_features, return_tensors="pt")

        # get the tokenized label sequences
        label_features = [{"input_ids": feature["labels"]} for feature in features]
        # pad the labels to max length
        labels_batch = self.processor.tokenizer.pad(label_features, return_tensors="pt")

        # replace padding with -100 to ignore loss correctly
        labels = labels_batch["input_ids"].masked_fill(labels_batch.attention_mask.ne(1), -100)

        # if bos token is appended in previous tokenization step,
        # cut bos token here as it's append later anyways
        if (labels[:, 0] == self.decoder_start_token_id).all().cpu().item():
            labels = labels[:, 1:]

        batch["labels"] = labels

        return batch


processor = WhisperProcessor.from_pretrained(base_model, language="English", task="transcribe")

model = WhisperForConditionalGeneration.from_pretrained(base_model)

model.generation_config.language = "English"
model.generation_config.task = "transcribe"

model.generation_config.forced_decoder_ids = None

data_collator = DataCollatorSpeechSeq2SeqWithPadding(
    processor=processor,
    decoder_start_token_id=model.config.decoder_start_token_id,
)

import evaluate

metric = evaluate.load("wer")


def compute_metrics(pred):
    pred_ids = pred.predictions
    label_ids = pred.label_ids

    # replace -100 with the pad_token_id
    label_ids[label_ids == -100] = tokenizer.pad_token_id

    # we do not want to group tokens when computing the metrics
    pred_str = tokenizer.batch_decode(pred_ids, skip_special_tokens=True)
    label_str = tokenizer.batch_decode(label_ids, skip_special_tokens=True)

    wer = 100 * metric.compute(predictions=pred_str, references=label_str)

    return {"wer": wer}


from transformers import Seq2SeqTrainingArguments

training_args = Seq2SeqTrainingArguments(
    output_dir="./model/training",  # change to a repo name of your choice
    per_device_train_batch_size=16,
    gradient_accumulation_steps=1,  # increase by 2x for every 2x decrease in batch size
    learning_rate=1e-5,
    warmup_steps=500,
    max_steps=5000,
    gradient_checkpointing=True,
    fp16=True,
    evaluation_strategy="steps",
    per_device_eval_batch_size=8,
    predict_with_generate=True,
    generation_max_length=225,
    save_steps=1000,
    eval_steps=1000,
    logging_steps=25,
    report_to=["tensorboard"],
    load_best_model_at_end=True,
    metric_for_best_model="wer",
    greater_is_better=False,
    push_to_hub=False,
)

from transformers import Seq2SeqTrainer

trainer = Seq2SeqTrainer(
    args=training_args,
    model=model,
    train_dataset=training_dataset,
    eval_dataset=testing_dataset,
    data_collator=data_collator,
    compute_metrics=compute_metrics,
    tokenizer=processor.feature_extractor,
)


processor.save_pretrained(training_args.output_dir)

trainer.train()

# save the model
save_directory = "model/whisper-finetuned"
import os
os.makedirs(save_directory, exist_ok=True)

trainer.save_model(save_directory)

processor.save_pretrained(save_directory)
