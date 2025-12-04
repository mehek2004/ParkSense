from datetime import datetime
from app import db
from app.models.parking_garage import ParkingGarage
from app.models.parking_spot import ParkingSpot
from app.models.sensor import Sensor
from app.models.camera import Camera

def init_db():
    """initialize database with tables"""
    db.create_all()
    print("Database tables created successfully")

def populate_sample_data():
    """populate database with sample garage data"""
    if ParkingGarage.query.first():
        print("Sample data already exists. Skipping population.")
        return

    garages_data = [
        {
            "name": "North Parking Garage",
            "address": "330 S 7th Street, San Jose, CA 95112",
            "total_floors": 5,
            "total_spaces": 1640  
        },
        {
            "name": "South Parking Garage",
            "address": "288 S 7th Street, San Jose, CA 95112",
            "total_floors": 6,
            "total_spaces": 1968  
        },
        {
            "name": "West Parking Garage",
            "address": "425 E San Carlos Street, San Jose, CA 95112",
            "total_floors": 4,
            "total_spaces": 1312  
        }
    ]

    for garage_data in garages_data:
        garage = ParkingGarage(
            name=garage_data["name"],
            address=garage_data["address"],
            total_floors=garage_data["total_floors"],
            total_spaces=garage_data["total_spaces"],
            open_spaces=garage_data["total_spaces"]
        )
        db.session.add(garage)
        db.session.flush()  

        for floor in range(1, garage_data["total_floors"] + 1):
            camera = Camera(
                garage_id=garage.garage_id,
                floor_number=floor,
                status="active",
                last_ping=datetime.utcnow()
            )
            db.session.add(camera)

        spots_per_floor = garage_data["total_spaces"] // garage_data["total_floors"]

        for floor in range(1, garage_data["total_floors"] + 1):
            for spot_num in range(1, spots_per_floor + 1):
                if spot_num <= 5:
                    spot_type = 'handicap'
                elif spot_num <= 10:
                    spot_type = 'staff'
                elif spot_num <= 15:
                    spot_type = 'ev'
                else:
                    spot_type = 'regular'

                spot = ParkingSpot(
                    garage_id=garage.garage_id,
                    floor_number=floor,
                    spot_number=spot_num,
                    spot_type=spot_type,
                    is_occupied=False,
                    last_updated=datetime.utcnow()
                )
                db.session.add(spot)
                db.session.flush()  

                sensor = Sensor(
                    parking_space_id=spot.space_id,
                    status="active",
                    last_reading=100.0,  
                    battery_level=100,
                    last_ping=datetime.utcnow()
                )
                db.session.add(sensor)

    db.session.commit()
    print(f"Sample data created")

def reset_db():
    """Drop all tables and recreate them"""
    db.drop_all()
    print("All tables dropped")
    init_db()
    populate_sample_data()
    print("Database reset complete")
