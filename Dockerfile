FROM golang:1.26-bookworm

WORKDIR /src

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates ffmpeg curl python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*


RUN pip3 install --no-cache-dir --break-system-packages edge-tts

# yt-dlp for !mp3/!mp4 YouTube downloads.
RUN pip3 install --no-cache-dir --break-system-packages edge-tts yt-dlp

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=1 go build -trimpath -ldflags="-s -w" -o /app/sonicos ./cmd/bot

# Copy static dashboard assets into the runtime image
RUN mkdir -p /app/cmd/static
COPY cmd/static/index.html /app/cmd/static/index.html

WORKDIR /app
RUN mkdir -p /app/data

ENV DATABASE_DRIVER=sqlite3
ENV DATABASE_URL=file:./data/sonicos.db?_foreign_keys=on&_journal_mode=WAL&_busy_timeout=5000
ENV BOT_PREFIX=!
ENV WORKERS=8
ENV QUEUE_SIZE=512
ENV LOG_LEVEL=info
ENV FFMPEG_PATH=ffmpeg

EXPOSE 8080

CMD ["/app/sonicos"]
