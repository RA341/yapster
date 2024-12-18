# Yapster

Convert voice to text and detect gender model

Hosted instance - [yap.dumbapps.org](https://yap.dumbapps.org)

## Technologies

* Python based backend

* Flutter based frontend

## File structure 

* ```client``` - contains the flutter frontend
    * ```lib``` - contains the main application code
* ```ml``` - contains the notebooks used in training the models
* ```backend``` - contains the backend code as well as the trained models
    *  ```model``` - contains the ASR model 
    * ```voice_model``` - contains the gender detection model

## Building

### Using docker (Recommended) 

I recommend using [docker](https://docs.docker.com/engine/install/) for building as avoids setting up flutter and python venv shenanigans and avoids installing packages into your system python.

Optionally you can setup [Nvidia container toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) to use your nvidia GPU, but it is not required to build the application.

#### Build the image
```bash
docker build . -t "yapster"
``` 
#### Run the image
```bash
docker run -p 8000:8000 yapster 
```

This will make the website accessible on [localhost:8000](http://localhost:8000)

### Manually building from source

#### Prerequisites
* You will need [flutter](https://docs.flutter.dev/get-started/install) installed and accessible, you can check your installation by running
    ```
    flutter doctor
    ```

* Python 3.12 installed

#### Build the frontend
This will build frontend files in ```client/build/web/```

```bash
cd client
flutter build web --base-href=/static/
```

#### Build the backend

##### Install packages

```bash
 pip install -r backend/requirements.txt 
```
##### Run the backend 
By default, it will automatically serve the generated frontend files ```client/build/web/```

```
py main.py
```

This will make the website accessible on [localhost:8000](http://localhost:8000)
