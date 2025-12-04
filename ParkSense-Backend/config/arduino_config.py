class ArduinoConfig:
    TOKEN_URL = "https://api2.arduino.cc/iot/v1/clients/token"
    PROPERTIES_URL_TEMPLATE = "https://api2.arduino.cc/iot/v2/things/{thing_id}/properties"

    GRANT_TYPE = "client_credentials"
    AUDIENCE = "https://api2.arduino.cc/iot"

    OCCUPIED_DISTANCE = 15.0   
    AVAILABLE_DISTANCE = 100.0  

    DEFAULT_MAX_RETRIES = 3
    DEFAULT_RETRY_DELAY = 2  
    DEFAULT_TIMEOUT = 10  

    RATE_LIMIT_REQUESTS = 10
    RATE_LIMIT_PERIOD = 1  

    @staticmethod
    def get_properties_url(thing_id):
        return ArduinoConfig.PROPERTIES_URL_TEMPLATE.format(thing_id=thing_id)

    @staticmethod
    def convert_boolean_to_distance(is_available):
        return ArduinoConfig.AVAILABLE_DISTANCE if is_available else ArduinoConfig.OCCUPIED_DISTANCE
