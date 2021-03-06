FROM continuumio/miniconda3

RUN apt-get -y update && apt-get install -y libzbar-dev ffmpeg libavcodec-extra

WORKDIR /src

# copy conda, environment configuration files
COPY ./env/environment.yml .

SHELL ["/bin/bash", "--login", "-c"]

# recreate conda environment
RUN conda env create -f environment.yml

# copy project source files
COPY ./src/ .

RUN conda activate tts-env \
	&& cd Grad-TTS/model/monotonic_align \
	&& python setup.py build_ext --inplace

RUN conda activate tts-env \
	&& python -c "from classifier import classify; import sys; sys.path.append('./Grad-TTS/'); from inference import say"

CMD conda activate tts-env \
	&& gunicorn --bind 0.0.0.0:8000 --workers 3 server:app