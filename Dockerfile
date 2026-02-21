FROM python:3.11-slim
WORKDIR /app
COPY . .

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "app.py"]

#run gunicorn binding to port 80
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:80", "app:app"]

# -w 4 --> use 4 worker processes 
#-b 0.0.0.0:80 --> bind to all interfaces on port 80
#app:app -> tells Gunicorn to load the app object from app.py


