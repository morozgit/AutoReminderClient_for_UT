import requests
import json

BASE_URL = "http://10.42.0.1:8000"

def get_reminders():
    try:
        response = requests.get(f"{BASE_URL}/api/parts", timeout=5)
        response.raise_for_status()
        return {"message": str(response.json().get("message", "Нет данных"))}
    except requests.exceptions.RequestException as e:
        return {"message": f"Network error: {str(e)}"}


def set_mileage(value):
    try:
        mileage = int(value) * 1000
        payload = {"mileage": mileage}

        response = requests.post(f"{BASE_URL}/api/get_num", json=payload)
        response.raise_for_status()

        return json.dumps(response.json(), ensure_ascii=False)
    except ValueError:
        return json.dumps({"error": "Ошибка: введено не число"}, ensure_ascii=False)
    except requests.RequestException as e:
        return json.dumps({"error": f"Ошибка сети: {str(e)}"}, ensure_ascii=False)
