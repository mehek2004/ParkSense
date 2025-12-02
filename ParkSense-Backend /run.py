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

if __name__ == '__main__':
    with app.app_context():
        init_db()

    app.run(
        host=app.config.get('HOST', '0.0.0.0'),
        port=app.config.get('PORT', 5000),
        debug=app.config.get('DEBUG', True)
    )
