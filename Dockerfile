# Use an official Python base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy current directory contents into the container
COPY . .

# Install dependencies
RUN pip install flask

# Expose port 5000
EXPOSE 5000

# Command to run the app
CMD ["python", "app.py"]