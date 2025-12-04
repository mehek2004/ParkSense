import logging
from app.services.arduino_cloud_service import ArduinoCloudService
from app.services.polling_service import PollingService

logger = logging.getLogger(__name__)


def register_jobs(scheduler, app):
    """
    Register all scheduled jobs with the scheduler

    Args:
        scheduler: APScheduler instance
        app: Flask application instance
    """
    logger.info("Registering scheduled jobs...")
    client_id = app.config.get('ARDUINO_CLIENT_ID')
    client_secret = app.config.get('ARDUINO_CLIENT_SECRET')
    thing_id = app.config.get('ARDUINO_THING_ID')

    if not client_id or not client_secret:
        logger.error("Arduino Cloud credentials not configured! Please set ARDUINO_CLIENT_ID and ARDUINO_CLIENT_SECRET")
        logger.error("Polling job NOT registered")
        return

    if client_id == 'your_client_id_here' or client_secret == 'your_client_secret_here':
        logger.warning("Arduino Cloud credentials appear to be placeholder values")
        logger.warning("Please update ARDUINO_CLIENT_ID and ARDUINO_CLIENT_SECRET in .env")
        logger.warning("Polling job NOT registered")
        return

    arduino_service = ArduinoCloudService(
        client_id=client_id,
        client_secret=client_secret,
        thing_id=thing_id,
        max_retries=app.config.get('ARDUINO_MAX_RETRIES', 3)
    )

    polling_service = PollingService(app, arduino_service)

    interval = app.config.get('ARDUINO_POLL_INTERVAL', 5)

    scheduler.add_job(
        func=polling_service.poll_and_update,
        trigger='interval',
        seconds=interval,
        id='arduino_cloud_poll',
        name='Arduino Cloud Polling',
        replace_existing=True,
        max_instances=1
    )

    logger.info(f"Registered Arduino Cloud polling job (interval: {interval} seconds)")

    if not hasattr(app, 'extensions'):
        app.extensions = {}
    app.extensions['polling_service'] = polling_service

    logger.info("All scheduled jobs registered successfully")
