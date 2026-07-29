"""
Seeds NexusFlow AI with dummy HRs, team members, financial data, and
richly-detailed tasks for testing every screen.
Run: python seed_data.py

Requires: pip install requests
"""
import requests
from datetime import datetime, timedelta

BASE_URL = "http://127.0.0.1:8000/api"

# ── 1. Log in as your existing CEO account ──────────────────────
CEO_EMAIL = "admin@nexusflow.dev"
CEO_PASSWORD = "DevPass2026!"

login_res = requests.post(f"{BASE_URL}/auth/login", json={
    "username": CEO_EMAIL,
    "password": CEO_PASSWORD,
})
login_res.raise_for_status()
token = login_res.json()["access_token"]
headers = {"Authorization": f"Bearer {token}"}

me = requests.get(f"{BASE_URL}/users/me", headers=headers).json()
company_id = me["company_id"]
print(f"Logged in as {me['full_name']} (company_id={company_id})")

# ── 2. Create 2 HR users — with salary set for financial screens ──
hrs = [
    {"email": "priya.hr@nexusflow.dev", "full_name": "Priya Ramesh", "position": "HR Manager", "salary": 65000},
    {"email": "ravi.hr@nexusflow.dev", "full_name": "Ravi Kumar", "position": "HR Manager", "salary": 62000},
]

hr_ids = []
for hr in hrs:
    payload = {
        "email": hr["email"],
        "full_name": hr["full_name"],
        "password": "HrPass2026!",
        "position": hr["position"],
        "role": "admin",
        "company_id": company_id,
        "salary": hr["salary"],
    }
    res = requests.post(f"{BASE_URL}/users/", json=payload, headers=headers)
    if res.status_code == 201:
        user = res.json()
        hr_ids.append(user["id"])
        print(f"Created HR: {user['full_name']} ({user['id']})")
    else:
        print(f"Failed to create {hr['email']}: {res.status_code} {res.text}")

# ── 3. Create team members — with payment_rate (hourly) set ──────
members = [
    {"email": "sara.dev@nexusflow.dev", "full_name": "Sara Malik", "position": "Support Lead", "parent": 0, "rate": 35},
    {"email": "tom.dev@nexusflow.dev", "full_name": "Tom Lee", "position": "Developer", "parent": 0, "rate": 48},
    {"email": "amy.design@nexusflow.dev", "full_name": "Amy Chen", "position": "Designer", "parent": 1, "rate": 42},
    {"email": "jake.acct@nexusflow.dev", "full_name": "Jake Wilson", "position": "Accountant", "parent": 1, "rate": 38},
]

member_ids = []
for m in members:
    if m["parent"] >= len(hr_ids):
        print(f"Skipping {m['email']} — not enough HRs created")
        continue
    payload = {
        "email": m["email"],
        "full_name": m["full_name"],
        "password": "MemberPass2026!",
        "position": m["position"],
        "role": "member",
        "company_id": company_id,
        "parent_id": hr_ids[m["parent"]],
        "payment_rate": m["rate"],
    }
    res = requests.post(f"{BASE_URL}/users/", json=payload, headers=headers)
    if res.status_code == 201:
        user = res.json()
        member_ids.append(user["id"])
        print(f"Created member: {user['full_name']} ({user['id']}) under HR {hr_ids[m['parent']]}")
    else:
        print(f"Failed to create {m['email']}: {res.status_code} {res.text}")

# ── 4. Create tasks — with client info, requirements, payment data ─
if member_ids:
    tasks = [
        {
            "title": "Client onboarding deck — Nimbus Co.",
            "priority": "high", "status": "in_progress", "days_out": 1, "assignee": 0,
            "client_name": "Alex Turner", "company_name": "Nimbus Co.",
            "requirements": "Prepare a 10-slide onboarding deck covering product overview, "
                             "pricing tiers, and implementation timeline for the client kickoff call.",
            "estimated_hours": 6, "payment_amount": 480, "is_paid": False,
        },
        {
            "title": "Fix login bug on Android",
            "priority": "urgent", "status": "overdue", "days_out": -1, "assignee": 1,
            "client_name": None, "company_name": None,
            "requirements": "Users report login failing intermittently on Android 13+. "
                             "Reproduce, identify root cause, ship a fix.",
            "estimated_hours": 4, "payment_amount": None, "is_paid": False,
        },
        {
            "title": "Design new dashboard mockups",
            "priority": "medium", "status": "pending", "days_out": 5,
            "assignee": 2 % len(member_ids),
            "client_name": "Priya Sharma", "company_name": "Fenwick Retail",
            "requirements": "Redesign the analytics dashboard with the new brand palette. "
                             "Deliver Figma file with desktop and mobile breakpoints.",
            "estimated_hours": 10, "payment_amount": 900, "is_paid": True,
        },
        {
            "title": "Invoice reconciliation — Q3",
            "priority": "high", "status": "pending", "days_out": 2,
            "assignee": 3 % len(member_ids),
            "client_name": None, "company_name": "Orbit Studio",
            "requirements": "Reconcile all Q3 client invoices against payments received. "
                             "Flag discrepancies for follow-up.",
            "estimated_hours": 5, "payment_amount": 350, "is_paid": False,
        },
        {
            "title": "Weekly team standup notes",
            "priority": "low", "status": "completed", "days_out": 3, "assignee": 0,
            "client_name": None, "company_name": None,
            "requirements": "Summarize this week's standup and circulate to the team.",
            "estimated_hours": 1, "payment_amount": None, "is_paid": False,
        },
        {
            "title": "Marketing site copy refresh",
            "priority": "medium", "status": "in_progress", "days_out": 7,
            "assignee": 1 % len(member_ids),
            "client_name": "Dana White", "company_name": "Nimbus Co.",
            "requirements": "Rewrite homepage and pricing page copy to reflect the new "
                             "positioning discussed in the strategy call.",
            "estimated_hours": 8, "payment_amount": 620, "is_paid": True,
        },
    ]

    for t in tasks:
        assignee_id = member_ids[t["assignee"] % len(member_ids)]
        due_date = (datetime.utcnow() + timedelta(days=t["days_out"])).isoformat()

        form_data = {
            "title": (None, t["title"]),
            "assignee_id": (None, assignee_id),
            "due_date": (None, due_date),
            "priority": (None, t["priority"]),
            "category": (None, "general"),
            "status": (None, t["status"]),
            "requirements": (None, t["requirements"]),
            "estimated_hours": (None, str(t["estimated_hours"])),
        }
        if t["client_name"]:
            form_data["client_name"] = (None, t["client_name"])
        if t["company_name"]:
            form_data["company_name"] = (None, t["company_name"])
        if t["payment_amount"]:
            form_data["payment_amount"] = (None, str(t["payment_amount"]))

        res = requests.post(f"{BASE_URL}/tasks/", files=form_data, headers=headers)
        if res.status_code == 201:
            task = res.json()
            print(f"Created task: {task['title']} → assignee {assignee_id}")

            # Mark as paid via update, if applicable (payment_amount was
            # already set on create; is_paid needs a follow-up PUT since
            # it's not in the create schema)
            if t["is_paid"] and t["payment_amount"]:
                requests.put(
                    f"{BASE_URL}/tasks/{task['id']}",
                    json={"is_paid": True},
                    headers=headers,
                )
        else:
            print(f"Failed to create task '{t['title']}': {res.status_code} {res.text}")
else:
    print("No members created — skipping tasks")

print("\nSeed complete.")
print("CEO login (financials/analytics): admin@nexusflow.dev / DevPass2026!")
print("HR login: priya.hr@nexusflow.dev / HrPass2026!")
print("Member login: sara.dev@nexusflow.dev / MemberPass2026!")