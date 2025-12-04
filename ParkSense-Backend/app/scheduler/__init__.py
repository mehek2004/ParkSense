"""
APScheduler Initialization
Background scheduler for Arduino Cloud polling
"""
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.executors.pool import ThreadPoolExecutor
import atexit
import logging

logger = logging.getLogger(__name__)

scheduler = None


def init_scheduler(app):
    """
    Initialize and start the APScheduler

    Args:
        app: Flask application instance

    Returns:
        BackgroundScheduler: Scheduler instance or None if disabled
    """
    global scheduler

    if not app.config.get('ARDUINO_POLL_ENABLED', False):
        logger.info("Arduino Cloud polling is disabled (ARDUINO_POLL_ENABLED=False)")
        return None

    logger.info("Initializing Arduino Cloud polling scheduler...")

    # Configure scheduler
    executors = {
        'default': ThreadPoolExecutor(max_workers=2)
    }

    job_defaults = {
        'coalesce': True,  # Combine missed runs into one
        'max_instances': 1,  # Only one instance of job at a time
        'misfire_grace_time': 30  # Allow 30s grace for missed jobs
    }

    scheduler = BackgroundScheduler(
        executors=executors,
        job_defaults=job_defaults,
        timezone='UTC'
    )

    # Register jobs
    from app.scheduler.jobs import register_jobs
    register_jobs(scheduler, app)

    # Start scheduler
    scheduler.start()
    logger.info("Scheduler started successfully")

    # Shutdown scheduler when app exits
    atexit.register(lambda: shutdown_scheduler())

    return scheduler


def shutdown_scheduler():
    """Shutdown the scheduler gracefully"""
    global scheduler
    if scheduler and scheduler.running:
        logger.info("Shutting down scheduler...")
        scheduler.shutdown(wait=False)
        logger.info("Scheduler shut down")
