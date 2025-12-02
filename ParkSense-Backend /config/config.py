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

class DevelopmentConfig(Config):
    DEBUG = True

class ProductionConfig(Config):
    DEBUG = False

class TestingConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
