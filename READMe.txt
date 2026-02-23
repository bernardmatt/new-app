# Daily App Deployment Guide

This guide explains how to set up, containerize, and automate daily builds for a simple Flask app using Docker, Gunicorn, and GitHub Actions. Each step includes detailed explanations.

---

## 1. Create Project Structure

Create a new folder:
    mkdir daily-app
    cd daily-app

Inside, create files:
    ├── app.py
    ├── requirements.txt
    ├── Dockerfile
    ├── test_app.py
    └── .github/
        └── workflows/
            └── daily.yml

Explanation:
- `app.py` contains the Flask app.
- `requirements.txt` lists dependencies.
- `Dockerfile` defines how to build the container.
- `test_app.py` contains automated tests.
- `.github/workflows/daily.yml` automates daily builds and pushes.

---

## 2. Write the Flask App

Create `app.py`:
    from flask import Flask
    app = Flask(__name__)

    @app.route("/")
    def home():
        return "Hello from Daily App!"

Explanation:
- Defines a simple Flask app with one route (`/`).
- Returns a greeting message.

---

## 3. Add Dependencies

Create `requirements.txt`:
    flask
    gunicorn
    pytest

Explanation:
- `flask` is the web framework.
- `gunicorn` is a production-ready WSGI server.
- `pytest` is used for automated testing.

---

## 4. Write a Test

Create `test_app.py`:
    from app import app

    def test_home():
        client = app.test_client()
        response = client.get("/")
        assert response.status_code == 200
        assert b"Hello from Daily App!" in response.data

Explanation:
- Uses Flask’s test client.
- Ensures `/` returns status 200 and the expected message.

---

## 5. Create Dockerfile

Write `Dockerfile`:
    FROM python:3.11-slim

    WORKDIR /app
    COPY . .

    RUN pip install --no-cache-dir -r requirements.txt

    # Run Gunicorn, binding to port 80
    CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:80", "app:app"]

Explanation:
- Uses Python 3.11 slim image.
- Installs dependencies.
- Runs Gunicorn with 4 workers on port 80.
- Loads `app` object from `app.py`.

---

## 6. Build and Run Locally

Build the image:
    docker build -t daily-app .

Run the container:
    docker run -p 8888:80 daily-app

Visit:
    http://localhost:8888

Explanation:
- Maps host port 8888 to container port 80.
- Gunicorn serves the app reliably.

---

## 7. Push Code to GitHub

Initialize and push:
    git init
    git remote add origin https://github.com/YOUR_USERNAME/daily-app.git
    git add .
    git commit -m "Initial commit"
    git push -u origin main

Explanation:
- Stores your project in GitHub for automation.

---

## 8. Automate Daily Builds with GitHub Actions

Create `.github/workflows/daily.yml`:
    name: Daily Docker Build

    on:
      schedule:
        - cron: "0 0 * * *"   # daily at midnight UTC
      workflow_dispatch:

    jobs:
      test-and-build:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4

          - name: Set up Python
            uses: actions/setup-python@v5
            with:
              python-version: '3.11'

          - name: Install dependencies
            run: pip install -r requirements.txt

          - name: Run tests
            run: pytest

          - name: Log in to GHCR
            run: echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin

          - name: Build Docker image
            run: docker build -t ghcr.io/${{ github.actor }}/daily-app:latest .

          - name: Push Docker image
            run: docker push ghcr.io/${{ github.actor }}/daily-app:latest

Explanation:
- Runs daily at midnight UTC.
- Installs dependencies and runs tests.
- Builds Docker image only if tests pass.
- Pushes image to GitHub Container Registry (GHCR).

---

## 9. Pull and Run Anywhere

On any machine:
    docker pull ghcr.io/YOUR_USERNAME/daily-app:latest
    docker run -p 5000:80 ghcr.io/YOUR_USERNAME/daily-app:latest

Visit:
    http://localhost:5000

Explanation:
- Pulls the latest daily build from GHCR.
- Runs the container with host port 5000 mapped to container port 80.

---

## Done!

You now have:
- A Flask app served by Gunicorn.
- Dockerized and running locally.
- Automated daily builds with tests.
- Images pushed to GHCR for easy deployment anywhere.

