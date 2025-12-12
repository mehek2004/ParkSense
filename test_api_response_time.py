import requests
import time
import statistics
from typing import List, Dict

BASE_URL = "http://127.0.0.1:5000/api/v1"
NUM_REQUESTS = 10  

def measure_response_time(url: str, method: str = "GET") -> float:
   
    start_time = time.perf_counter()
    try:
        if method == "GET":
            response = requests.get(url, timeout=30)
        elif method == "POST":
            response = requests.post(url, timeout=30)
        end_time = time.perf_counter()

        response_time_ms = (end_time - start_time) * 1000

        if response.status_code in [200, 201]:
            return response_time_ms
        else:
            print(f"  Warning: Status code {response.status_code} for {url}")
            return response_time_ms
    except requests.exceptions.RequestException as e:
        print(f"  Error: {e}")
        return -1

def test_endpoint(name: str, url: str, method: str = "GET") -> Dict:
    
    print(f"\nTesting: {name}")
    print(f"URL: {url}")

    response_times = []

    for i in range(NUM_REQUESTS):
        response_time = measure_response_time(url, method)
        if response_time > 0:
            response_times.append(response_time)
            print(f"  Request {i+1}/{NUM_REQUESTS}: {response_time:.2f} ms")
        else:
            print(f"  Request {i+1}/{NUM_REQUESTS}: FAILED")

    if not response_times:
        return {
            "name": name,
            "url": url,
            "status": "FAILED",
            "avg": 0,
            "min": 0,
            "max": 0,
            "median": 0
        }

    avg_time = statistics.mean(response_times)
    min_time = min(response_times)
    max_time = max(response_times)
    median_time = statistics.median(response_times)

    status = "✓ PASS" if avg_time < 500 else "✗ SLOW"

    print(f"\n  Average: {avg_time:.2f} ms")
    print(f"  Min: {min_time:.2f} ms")
    print(f"  Max: {max_time:.2f} ms")
    print(f"  Median: {median_time:.2f} ms")
    print(f"  Status: {status}")

    return {
        "name": name,
        "url": url,
        "status": status,
        "avg": avg_time,
        "min": min_time,
        "max": max_time,
        "median": median_time
    }

def main():
    """Run API response time tests"""
    print("=" * 70)
    print("ParkSense API Response Time Test")
    print("=" * 70)
    print(f"Base URL: {BASE_URL}")
    print(f"Requests per endpoint: {NUM_REQUESTS}")
    print(f"Target response time: < 500ms")

    try:
        requests.get(f"{BASE_URL}/garages", timeout=5)
    except requests.exceptions.RequestException:
        print("\n❌ ERROR: Cannot connect to API. Make sure the Flask server is running.")
        print("   Run: cd ParkSense-Backend && python run.py")
        return

    endpoints = [
        ("Get All Garages", f"{BASE_URL}/garages", "GET"),
        ("Get Garage by ID", f"{BASE_URL}/garages/1", "GET"),
        ("Get Garage Availability", f"{BASE_URL}/garages/1/availability", "GET"),
        ("Get Floor Availability", f"{BASE_URL}/garages/1/floors/1", "GET"),
        ("Get Spots by Type", f"{BASE_URL}/garages/1/spots/type/regular", "GET"),
        ("Get Sensor Health", f"{BASE_URL}/sensors/health", "GET"),
        ("Get Polling Status", f"{BASE_URL}/polling/status", "GET"),
    ]

    results = []

    for name, url, method in endpoints:
        result = test_endpoint(name, url, method)
        results.append(result)

    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print(f"{'Endpoint':<30} {'Avg (ms)':<12} {'Min (ms)':<12} {'Max (ms)':<12} {'Status':<10}")
    print("-" * 70)

    for result in results:
        if result["avg"] > 0:
            print(f"{result['name'][:29]:<30} {result['avg']:<12.2f} {result['min']:<12.2f} {result['max']:<12.2f} {result['status']:<10}")
        else:
            print(f"{result['name'][:29]:<30} {'FAILED':<12} {'FAILED':<12} {'FAILED':<12} {'✗ FAIL':<10}")

    print("=" * 70)

    successful_results = [r for r in results if r["avg"] > 0]
    if successful_results:
        overall_avg = statistics.mean([r["avg"] for r in successful_results])
        print(f"\nOverall Average Response Time: {overall_avg:.2f} ms")

        passed = len([r for r in successful_results if "PASS" in r["status"]])
        total = len(successful_results)
        print(f"Endpoints Meeting Target (<500ms): {passed}/{total}")

        if overall_avg < 500:
            print("\n✓ API performance meets target!")
        else:
            print("\n✗ API performance needs optimization")
    else:
        print("\n✗ All tests failed")

if __name__ == "__main__":
    main()
