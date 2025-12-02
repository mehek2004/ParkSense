from datetime import datetime, timedelta
from app import db
from app.models.sensor import Sensor
from app.models.parking_spot import ParkingSpot
from app.services.parking_service import ParkingService

class SensorService:
    OCCUPIED_THRESHOLD = 30  

    @staticmethod
    def process_sensor_reading(sensor_id, distance_reading):
        sensor = Sensor.query.get(sensor_id)
        if not sensor:
            return {'error': 'Sensor not found'}, 404

        sensor.last_reading = distance_reading
        sensor.last_ping = datetime.utcnow()

        is_occupied = distance_reading < SensorService.OCCUPIED_THRESHOLD

        result = ParkingService.update_spot_occupancy(
            sensor.parking_space_id,
            is_occupied
        )

        db.session.commit()

        return {
            'sensor_id': sensor_id,
            'distance': distance_reading,
            'is_occupied': is_occupied,
            'spot': result
        }

    @staticmethod
    def get_sensor_status(sensor_id):
        sensor = Sensor.query.get(sensor_id)
        if not sensor:
            return None

        time_since_ping = datetime.utcnow() - sensor.last_ping
        is_responsive = time_since_ping < timedelta(minutes=5)

        return {
            **sensor.to_dict(),
            'is_responsive': is_responsive,
            'time_since_ping': time_since_ping.total_seconds()
        }

    @staticmethod
    def update_battery_level(sensor_id, battery_level):
        sensor = Sensor.query.get(sensor_id)
        if not sensor:
            return None

        sensor.battery_level = battery_level

        if battery_level < 20:
            sensor.status = 'low_battery'
        elif sensor.status == 'low_battery' and battery_level >= 20:
            sensor.status = 'active'

        db.session.commit()
        return sensor.to_dict()

    @staticmethod
    def get_all_sensors_health():
        sensors = Sensor.query.all()

        healthy = []
        low_battery = []
        unresponsive = []

        for sensor in sensors:
            status = SensorService.get_sensor_status(sensor.sensor_id)

            if status['battery_level'] < 20:
                low_battery.append(status)
            elif not status['is_responsive']:
                unresponsive.append(status)
            else:
                healthy.append(status)

        return {
            'total_sensors': len(sensors),
            'healthy': len(healthy),
            'low_battery': len(low_battery),
            'unresponsive': len(unresponsive),
            'sensors': {
                'healthy': healthy,
                'low_battery': low_battery,
                'unresponsive': unresponsive
            }
        }
