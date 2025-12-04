import os
from app import create_app
from app.utils.db_init import init_db, populate_sample_data
from config.config import DevelopmentConfig, ProductionConfig, TestingConfig

config_map = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig
}

config_name = os.getenv('FLASK_CONFIG', 'development')
config_class = config_map.get(config_name, DevelopmentConfig)
app = create_app(config_class)

@app.cli.command()
def initdb():
    """initialize the database"""
    init_db()
    print("Database initialized successfully")

@app.cli.command()
def seeddb():
    """seed the database with sample data"""
    populate_sample_data()
    print("Database seeded with sample data")

@app.cli.command()
def resetdb():
    """reset database"""
    from app.utils.db_init import reset_db
    reset_db()
    print("Database reset complete")

@app.cli.command()
def poll_now():
    """trigger an immediate Arduino Cloud poll"""
    polling_service = app.extensions.get('polling_service')
    if polling_service:
        print("Triggering Arduino Cloud poll...")
        result = polling_service.poll_and_update()
        if result['success']:
            print(f"✓ Poll completed successfully")
            print(f"  Sensors updated: {result['sensors_updated']}")
            print(f"  Timestamp: {result['timestamp']}")
        else:
            print(f"✗ Poll failed: {result['error']}")
    else:
        print("✗ Polling service not enabled")
        print("  Set ARDUINO_POLL_ENABLED=True in .env to enable polling")

@app.cli.command()
def polling_status():
    """check Arduino Cloud polling service status"""
    polling_service = app.extensions.get('polling_service')
    if polling_service:
        status = polling_service.get_status()
        print("Arduino Cloud Polling Status:")
        print(f"  Enabled: {status['enabled']}")
        print(f"  Interval: {status['interval_seconds']} seconds")
        print(f"  Last poll: {status['last_poll_time'] or 'Never'}")
        print(f"  Last poll success: {status['last_poll_success']}")
        if status['last_error']:
            print(f"  Last error: {status['last_error']}")
        print(f"  Successful polls: {status['successful_polls']}")
        print(f"  Failed polls: {status['failed_polls']}")
        print(f"  Sensor count: {status['sensor_count']}")
    else:
        print("✗ Polling service not enabled")
        print("  Set ARDUINO_POLL_ENABLED=True in .env to enable polling")

if __name__ == '__main__':
    with app.app_context():
        init_db()

    app.run(
        host=app.config.get('HOST', '0.0.0.0'),
        port=app.config.get('PORT', 5000),
        debug=app.config.get('DEBUG', True)
    )
