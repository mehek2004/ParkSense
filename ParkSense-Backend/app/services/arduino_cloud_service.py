import requests
import logging
import time
from datetime import datetime, timedelta
from config.arduino_config import ArduinoConfig

logger = logging.getLogger(__name__)


class ArduinoCloudService:

    def __init__(self, client_id, client_secret, thing_id, max_retries=3):
        self.client_id = client_id
        self.client_secret = client_secret
        self.thing_id = thing_id
        self.max_retries = max_retries

        self._access_token = None
        self._token_expiry = None

        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json'
        })

    def get_access_token(self):
        if self._access_token and self._token_expiry:
            if datetime.utcnow() < self._token_expiry - timedelta(minutes=5):
                logger.debug("Using cached access token")
                return self._access_token

        logger.info("Requesting new access token from Arduino Cloud")

        token_data = {
            'grant_type': ArduinoConfig.GRANT_TYPE,
            'client_id': self.client_id,
            'client_secret': self.client_secret,
            'audience': ArduinoConfig.AUDIENCE
        }

        try:
            response = self.session.post(
                ArduinoConfig.TOKEN_URL,
                data=token_data,
                headers={'Content-Type': 'application/x-www-form-urlencoded'},
                timeout=ArduinoConfig.DEFAULT_TIMEOUT
            )

            response.raise_for_status()
            token_response = response.json()

            self._access_token = token_response['access_token']
            expires_in = token_response.get('expires_in', 3600)  
            self._token_expiry = datetime.utcnow() + timedelta(seconds=expires_in)

            logger.info(f"Access token acquired, expires in {expires_in} seconds")
            return self._access_token

        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to get access token: {str(e)}")
            self._access_token = None
            self._token_expiry = None
            raise Exception(f"Authentication failed: {str(e)}")

    def get_properties(self):
        access_token = self.get_access_token()

        url = ArduinoConfig.get_properties_url(self.thing_id)

        properties_data = self._request_with_retry(
            method='GET',
            url=url,
            headers={'Authorization': f'Bearer {access_token}'}
        )

        properties = {}
        for prop in properties_data:
            name = prop.get('name')
            value = prop.get('last_value')
            if name is not None and value is not None:
                properties[name] = value

        logger.info(f"Retrieved {len(properties)} properties from Arduino Cloud")
        logger.debug(f"Properties: {properties}")

        return properties

    def _request_with_retry(self, method, url, **kwargs):
        for attempt in range(self.max_retries):
            try:
                response = self.session.request(
                    method=method,
                    url=url,
                    timeout=ArduinoConfig.DEFAULT_TIMEOUT,
                    **kwargs
                )

                if response.status_code == 429:
                    retry_after = int(response.headers.get('Retry-After', ArduinoConfig.DEFAULT_RETRY_DELAY))
                    logger.warning(f"Rate limited, retrying after {retry_after}s")
                    time.sleep(retry_after)
                    continue

                if response.status_code == 401:
                    logger.warning("Authentication failed, clearing token cache")
                    self._access_token = None
                    self._token_expiry = None
                    if attempt < self.max_retries - 1:
                        continue
                    else:
                        raise Exception("Authentication failed after retries")

                response.raise_for_status()
                return response.json()

            except requests.exceptions.Timeout as e:
                logger.warning(f"Request timeout (attempt {attempt + 1}/{self.max_retries}): {str(e)}")
                if attempt < self.max_retries - 1:
                    delay = ArduinoConfig.DEFAULT_RETRY_DELAY * (2 ** attempt)  
                    time.sleep(delay)
                    continue
                else:
                    raise Exception(f"Request failed after {self.max_retries} attempts: {str(e)}")

            except requests.exceptions.RequestException as e:
                logger.warning(f"Request failed (attempt {attempt + 1}/{self.max_retries}): {str(e)}")
                if attempt < self.max_retries - 1:
                    delay = ArduinoConfig.DEFAULT_RETRY_DELAY * (2 ** attempt)  
                    time.sleep(delay)
                    continue
                else:
                    raise Exception(f"Request failed after {self.max_retries} attempts: {str(e)}")

        raise Exception("Max retries exceeded")
