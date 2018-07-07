#!/bin/bash

# Start Gunicorn processes
# Seems to be a good stable webserver
echo Starting Gunicorn.
exec gunicorn mysite.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 3
