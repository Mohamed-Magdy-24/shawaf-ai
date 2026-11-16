FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Loop synthetic test video to MediaMTX RTSP server
ENTRYPOINT ["ffmpeg", "-re", "-stream_loop", "-1", "-i", "/data/synthetic_intrusion_640x360.mp4", "-c", "copy", "-f", "rtsp", "rtsp://mediamtx:8554/bnf_cam_01"]
