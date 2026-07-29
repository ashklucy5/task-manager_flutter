"""
Patches existing tasks (ids 10-14) with financial/detail data that the
original short seed script didn't include.
Run: python patch_tasks.py
"""
import requests
from datetime import datetime, timezone, timedelta

BASE_URL = "http://127.0.0.1:8000/api"

CEO_EMAIL = "admin@nexusflow.dev"
CEO_PASSWORD = "DevPass2026!"

login_res = requests.post(f"{BASE_URL}/auth/login", json={
    "username": CEO_EMAIL,
    "password": CEO_PASSWORD,
})
login_res.raise_for_status()
token = login_res.json()["access_token"]
headers = {"Authorization": f"Bearer {token}"}

now = datetime.now(timezone.utc)

# task_id: fields to patch
updates = {
    10: {
        "status": "in_progress",
        "client_name": "Alex Turner",
        "company_name": "Nimbus Co.",
        "requirements": "Prepare a 10-slide onboarding deck covering product overview, "
                         "pricing tiers, and implementation timeline for the client kickoff call.",
        "estimated_hours": 6,
        "payment_amount": 480,
        "is_paid": False,
    },
    11: {
        "status": "overdue",
        "requirements": "Users report login failing intermittently on Android 13+. "
                         "Reproduce, identify root cause, ship a fix.",
        "estimated_hours": 4,
        "due_date": (now - timedelta(days=1)).isoformat(),
    },
    12: {
        "status": "pending",
        "client_name": "Priya Sharma",
        "company_name": "Fenwick Retail",
        "requirements": "Redesign the analytics dashboard with the new brand palette. "
                         "Deliver Figma file with desktop and mobile breakpoints.",
        "estimated_hours": 10,
        "payment_amount": 900,
        "is_paid": True,
    },
    13: {
        "status": "pending",
        "company_name": "Orbit Studio",
        "requirements": "Reconcile all Q3 client invoices against payments received. "
                         "Flag discrepancies for follow-up.",
        "estimated_hours": 5,
        "payment_amount": 350,
        "is_paid": False,
    },
    14: {
        "status": "completed",
        "requirements": "Summarize this week's standup and circulate to the team.",
        "estimated_hours": 1,
    },
}

for task_id, fields in updates.items():
    res = requests.put(f"{BASE_URL}/tasks/{task_id}", json=fields, headers=headers)
    if res.status_code == 200:
        print(f"Updated task {task_id}: {res.json()['title']}")
    else:
        print(f"Failed to update task {task_id}: {res.status_code} {res.text}")

print("\nDone. Re-check /financials/summary and /financials/tasks now.")