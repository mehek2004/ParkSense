from flask import jsonify, request, current_app
from app.routes import api_bp
from app.services.sensor_service import SensorService

@api_bp.route('/sensors/<int:sensor_id>/reading', methods=['POST'])
def submit_sensor_reading(sensor_id):
    data = request.get_json()

    if not data or 'distance' not in data:
        return jsonify({
            'success': False,
            'error': 'Distance reading required'
        }), 400

    try:
        distance = float(data['distance'])
    except (ValueError, TypeError):
        return jsonify({
            'success': False,
            'error': 'Invalid distance value'
        }), 400

    result = SensorService.process_sensor_reading(sensor_id, distance)

    if 'error' in result:
        return jsonify({
            'success': False,
            'error': result['error']
        }), 404

    return jsonify({
        'success': True,
        'data': result
    }), 200

@api_bp.route('/sensors/<int:sensor_id>', methods=['GET'])
def get_sensor_status(sensor_id):
    status = SensorService.get_sensor_status(sensor_id)

    if not status:
        return jsonify({
            'success': False,
            'error': 'Sensor not found'
        }), 404

    return jsonify({
        'success': True,
        'data': status
    }), 200

@api_bp.route('/sensors/<int:sensor_id>/battery', methods=['PUT'])
def update_battery_level(sensor_id):
    data = request.get_json()

    if not data or 'battery_level' not in data:
        return jsonify({
            'success': False,
            'error': 'Battery level required'
        }), 400

    try:
        battery_level = int(data['battery_level'])
        if battery_level < 0 or battery_level > 100:
            raise ValueError('Battery level must be between 0 and 100')
    except (ValueError, TypeError) as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 400

    result = SensorService.update_battery_level(sensor_id, battery_level)

    if not result:
        return jsonify({
            'success': False,
            'error': 'Sensor not found'
        }), 404

    return jsonify({
        'success': True,
        'data': result
    }), 200

@api_bp.route('/sensors/health', methods=['GET'])
def get_all_sensors_health():
    health = SensorService.get_all_sensors_health()

    return jsonify({
        'success': True,
        'data': health
    }), 200

@api_bp.route('/polling/status', methods=['GET'])
def get_polling_status():
    polling_service = current_app.extensions.get('polling_service')

    if not polling_service:
        return jsonify({
            'success': True,
            'data': {
                'enabled': False,
                'message': 'Polling service not initialized'
            }
        }), 200

    status = polling_service.get_status()

    return jsonify({
        'success': True,
        'data': status
    }), 200
