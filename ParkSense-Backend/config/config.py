import os
from dotenv import load_dotenv

basedir = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))
load_dotenv(os.path.join(basedir, '.env'))

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
        'sqlite:///' + os.path.join(basedir, 'parksense.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    API_VERSION = 'v1'

    SPOTS_PER_PAGE = 50

    SENSOR_UPDATE_THRESHOLD = 5  
    SENSOR_READING_WINDOW = 10   

    MAX_CONCURRENT_USERS = 200
    DATABASE_QUERY_TIMEOUT = 100 

    ARDUINO_CLIENT_ID = os.environ.get('ARDUINO_CLIENT_ID')
    ARDUINO_CLIENT_SECRET = os.environ.get('ARDUINO_CLIENT_SECRET')
    ARDUINO_THING_ID = os.environ.get('ARDUINO_THING_ID', '9d509034-3983-4bd7-9f08-0027587d72f3')
    ARDUINO_POLL_INTERVAL = int(os.environ.get('ARDUINO_POLL_INTERVAL', 5))  
    ARDUINO_POLL_ENABLED = os.environ.get('ARDUINO_POLL_ENABLED', 'True') == 'True'
    ARDUINO_MAX_RETRIES = int(os.environ.get('ARDUINO_MAX_RETRIES', 3))
    ARDUINO_OCCUPIED_DISTANCE = 15.0  
    ARDUINO_AVAILABLE_DISTANCE = 100.0  

    ARDUINO_SENSOR_MAPPING = {
        'space1': 1,
        'space2': 2,
        'space3': 3,
        'space4': 4
    }

class DevelopmentConfig(Config):
    DEBUG = True

class ProductionConfig(Config):
    DEBUG = False

class TestingConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
