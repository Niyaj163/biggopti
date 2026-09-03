"""
Biggopti BDapps SMS Notifier
Enables real-time SMS broadcasts for new high-priority notices and direct SMS alerts to subscribers.
"""

import os
import json
import requests
from pathlib import Path
from dotenv import load_dotenv

# Ensure environment variables are loaded
env_path = Path(__file__).resolve().parent / '.env'
load_dotenv(dotenv_path=env_path)

BDAPPS_APP_ID = os.getenv("BDAPPS_APP_ID")
BDAPPS_APP_PASSWORD = os.getenv("BDAPPS_APP_PASSWORD")
BDAPPS_SMS_URL = "https://developer.bdapps.com/sms/send"

def format_tel_address(phone: str) -> str:
    """Normalizes phone number to BDapps tel:8801xxxxxxxxx format."""
    digits = ''.join(filter(str.isdigit, phone))
    if digits.startswith("880"):
        pass
    elif digits.startswith("88"):
        digits = "880" + digits[2:]
    elif digits.startswith("01"):
        digits = "88" + digits
    return f"tel:{digits}"

def broadcast_notice_sms(title: str, deadline: str = "", org_name: str = "") -> dict:
    """
    Broadcasts a new notice summary via BDapps SMS to all subscribed users.
    Encoding '8' specifies Unicode (Bangla) encoding.
    """
    if not BDAPPS_APP_ID or not BDAPPS_APP_PASSWORD or BDAPPS_APP_ID == "APP_000000":
        print("[BDAPPS SMS] Credentials not configured or placeholder detected. Skipping broadcast.")
        return {"status": "SKIPPED", "message": "Placeholder credentials"}

    org_tag = f"[{org_name[:20]}] " if org_name else "[বিজ্ঞপ্তি] "
    deadline_tag = f" শেষ: {deadline}।" if deadline else ""
    # BDapps SMS character limit for single SMS unicode is 70 chars, multi-part supported
    message_text = f"{org_tag}{title[:50]}...{deadline_tag} বিস্তারিত অ্যাপে দেখুন।"

    payload = {
        "applicationId": BDAPPS_APP_ID,
        "password": BDAPPS_APP_PASSWORD,
        "version": "1.0",
        "message": message_text,
        "destinationAddresses": ["tel:all"],
        "encoding": "8",
    }

    try:
        response = requests.post(
            BDAPPS_SMS_URL,
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=15
        )
        data = response.json()
        status_code = data.get("statusCode", "")
        if status_code == "S1000":
            print(f"[BDAPPS SMS] Broadcast successful! Status: {status_code}")
        else:
            print(f"[BDAPPS SMS] Broadcast response: {data}")
        return data
    except Exception as e:
        print(f"[BDAPPS SMS] Broadcast failed with exception: {e}")
        return {"status": "ERROR", "error": str(e)}

def send_direct_sms(phone: str, message: str) -> dict:
    """Sends a direct SMS alert to a single subscriber."""
    if not BDAPPS_APP_ID or not BDAPPS_APP_PASSWORD or BDAPPS_APP_ID == "APP_000000":
        return {"status": "SKIPPED", "message": "Placeholder credentials"}

    address = format_tel_address(phone)
    payload = {
        "applicationId": BDAPPS_APP_ID,
        "password": BDAPPS_APP_PASSWORD,
        "version": "1.0",
        "message": message,
        "destinationAddresses": [address],
        "encoding": "8",
    }

    try:
        response = requests.post(
            BDAPPS_SMS_URL,
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=15
        )
        return response.json()
    except Exception as e:
        return {"status": "ERROR", "error": str(e)}

if __name__ == "__main__":
    print(f"BDapps Notifier Loaded. App ID: {BDAPPS_APP_ID}")
