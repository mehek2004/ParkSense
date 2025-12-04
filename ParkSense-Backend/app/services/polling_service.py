import logging
from datetime import datetime
from config.arduino_config import ArduinoConfig

logger = logging.getLogger(__name__)


class PollingService:
    def __init__(self, app, arduino_service):
        self.app = app
        self.arduino_service = arduino_service
        self.sensor_mapping = app.config['ARDUINO_SENSOR_MAPPING']
        self.occupied_distance = app.config.get('ARDUINO_OCCUPIED_DISTANCE', 15.0)
        self.available_distance = app.config.get('ARDUINO_AVAILABLE_DISTANCE', 100.0)

        self.last_poll_time = None
        self.last_poll_success = None
        self.last_error = None
        self.successful_polls = 0
        self.failed_polls = 0

    def poll_and_update(self):
        logger.info("Starting Arduino Cloud poll...")

        with self.app.app_context():
            try:
                properties = self.arduino_service.get_properties()

                if not properties:
                    logger.warning("No properties returned from Arduino Cloud")
                    self._update_status(success=False, error="No properties returned")
                    return {
                        'success': False,
                        'error': 'No properties returned',
                        'sensors_updated': 0
                    }

                results = []
                for property_name, is_available in properties.items():
                    sensor_id = self.sensor_mapping.get(property_name)

                    if sensor_id is None:
                        logger.warning(f"Unknown property name: {property_name}, skipping")
                        continue

                    try:
                        result = self._submit_sensor_reading(sensor_id, is_available)
                        results.append(result)
                        logger.debug(f"Updated sensor {sensor_id} ({property_name}): available={is_available}")

                    except Exception as e:
                        logger.error(f"Failed to update sensor {sensor_id}: {str(e)}")
                        continue

                self._update_status(success=True)
                logger.info(f"Poll completed successfully: {len(results)} sensors updated")

                return {
                    'success': True,
                    'sensors_updated': len(results),
                    'results': results,
                    'timestamp': datetime.utcnow().isoformat()
                }

            except Exception as e:
                logger.error(f"Poll failed: {str(e)}")
                self._update_status(success=False, error=str(e))

                return {
                    'success': False,
                    'error': str(e),
                    'sensors_updated': 0,
                    'timestamp': datetime.utcnow().isoformat()
                }

    def _submit_sensor_reading(self, sensor_id, is_available):
        distance = self.available_distance if is_available else self.occupied_distance

        from app.services.sensor_service import SensorService

        result = SensorService.process_sensor_reading(sensor_id, distance)

        return result

    def _update_status(self, success, error=None):
        self.last_poll_time = datetime.utcnow()
        self.last_poll_success = success
        self.last_error = error if not success else None

        if success:
            self.successful_polls += 1
        else:
            self.failed_polls += 1

    def get_status(self):
        return {
            'enabled': self.app.config.get('ARDUINO_POLL_ENABLED', False),
            'interval_seconds': self.app.config.get('ARDUINO_POLL_INTERVAL', 5),
            'last_poll_time': self.last_poll_time.isoformat() if self.last_poll_time else None,
            'last_poll_success': self.last_poll_success,
            'last_error': self.last_error,
            'successful_polls': self.successful_polls,
            'failed_polls': self.failed_polls,
            'sensor_count': len(self.sensor_mapping)
        }
