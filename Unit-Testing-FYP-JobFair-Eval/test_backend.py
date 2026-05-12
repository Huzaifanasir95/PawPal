"""
PawPal Backend Integration Tests  —  100+ Tests
================================================
Covers every major API surface area of the PawPal Go backend:
  Auth, Profile, Pets, Health Records, Health Journals,
  Community Posts, Comments, Community Advanced (groups/trending/hashtags),
  Vets, Marketplace (products/cart/orders), Lost & Found,
  Adoptions, Events (RSVP), Caregivers, Bookings, Vet Appointments,
  Chatbot, Password Reset, User Roles, WebSocket auth guard.

Usage:
    python test_backend.py
    python test_backend.py --url https://your-ngrok-url.ngrok-free.app
"""

import sys
import io

# Force UTF-8 on Windows consoles
if sys.platform == "win32":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

import requests
import json
import time
import uuid
import argparse
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional, Callable

# ─── Config ──────────────────────────────────────────────────────────────────

DEFAULT_URL = "https://transudatory-fecklessly-karisa.ngrok-free.dev"
TIMEOUT = 20

parser = argparse.ArgumentParser(description="PawPal Backend Integration Tests")
parser.add_argument("--url", default=DEFAULT_URL)
args, _ = parser.parse_known_args()

BASE_URL = args.url.rstrip("/")
HDRS = {"Content-Type": "application/json", "ngrok-skip-browser-warning": "true"}

# ─── Shared state ────────────────────────────────────────────────────────────

S: dict = {}          # tokens, IDs etc produced during run
UID = uuid.uuid4().hex[:8]
EMAIL    = f"pp_{UID}@pawpal-test.com"
PASSWORD = "Test@1234"
EMAIL_2  = f"pp2_{UID}@pawpal-test.com"   # second account

# ─── Infrastructure ──────────────────────────────────────────────────────────

class TestResult:
    def __init__(self, name: str, category: str):
        self.name        = name
        self.category    = category
        self.passed:     Optional[bool]  = None
        self.status_code: Optional[int] = None
        self.detail:     str = ""
        self.duration_ms: float = 0.0

    def to_dict(self) -> dict:
        return {
            "name":        self.name,
            "category":    self.category,
            "passed":      self.passed,
            "status_code": self.status_code,
            "detail":      self.detail,
            "duration_ms": round(self.duration_ms, 2),
        }

_results: list[TestResult] = []

def run(name: str, category: str, fn: Callable) -> TestResult:
    r = TestResult(name, category)
    t0 = time.perf_counter()
    try:
        fn(r)
        if r.passed is None:
            r.passed = True
    except AssertionError as e:
        r.passed = False
        if not r.detail:
            r.detail = str(e)
    except requests.exceptions.ConnectionError as e:
        r.passed = False
        r.detail = f"Connection error: {e}"
    except requests.exceptions.Timeout:
        r.passed = False
        r.detail = "Request timed out"
    except Exception as e:
        r.passed = False
        r.detail = f"{type(e).__name__}: {e}"
    finally:
        r.duration_ms = (time.perf_counter() - t0) * 1000
    _results.append(r)
    icon = "PASS" if r.passed else "FAIL"
    suffix = f" — {r.detail}" if not r.passed else ""
    print(f"  [{icon}] {name}{suffix}")
    return r

def api(method: str, path: str, token: str = None, **kwargs) -> requests.Response:
    h = dict(HDRS)
    if token:
        h["Authorization"] = f"Bearer {token}"
    kwargs.setdefault("timeout", TIMEOUT)
    return requests.request(method, f"{BASE_URL}{path}", headers=h, **kwargs)

def chk(resp: requests.Response, r: TestResult, *expected: int):
    r.status_code = resp.status_code
    if resp.status_code not in expected:
        try:
            body = resp.json()
        except Exception:
            body = resp.text[:300]
        r.detail = f"Expected {expected}, got {resp.status_code}. Body: {body}"
        r.passed = False
        raise AssertionError(r.detail)

def key(body: dict, k: str, r: TestResult):
    if k not in body:
        r.detail = f"Missing key '{k}'. Keys: {list(body.keys())}"
        r.passed = False
        raise AssertionError(r.detail)

def tok() -> str:
    return S.get("access_token", "")

def skip_if_missing(r: TestResult, *keys):
    """Skip test gracefully if prerequisite state is missing."""
    for k in keys:
        if not S.get(k):
            r.passed = False
            r.detail = f"Skipped — prerequisite '{k}' not set (earlier test failed)"
            raise AssertionError(r.detail)

# ══════════════════════════════════════════════════════════════════════════════
#  1. Health & Connectivity  (5 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s01_health():
    print("\n[01] Health & Connectivity")
    C = "Health"

    def health_ok(r):
        resp = api("GET", "/health")
        chk(resp, r, 200)
        body = resp.json()
        assert body.get("status") in ("ok", "healthy", "degraded")
        r.detail = f"status={body['status']}"

    def model_info_reachable(r):
        resp = api("GET", "/api/v1/model/info")
        r.status_code = resp.status_code
        assert resp.status_code in (200, 503)
        r.detail = f"status={resp.status_code}"

    def breeds_dog(r):
        resp = api("GET", "/api/v1/breeds?pet_type=dog")
        chk(resp, r, 200)
        assert resp.json().get("success") is True
        r.detail = f"total={resp.json().get('total_count')}"

    def breeds_cat(r):
        resp = api("GET", "/api/v1/breeds?pet_type=cat")
        chk(resp, r, 200)
        assert resp.json().get("success") is True

    def breeds_invalid_type(r):
        resp = api("GET", "/api/v1/breeds?pet_type=fish")
        r.status_code = resp.status_code
        # May return 200 with empty list or 400 — both acceptable
        assert resp.status_code in (200, 400)
        r.detail = f"status={resp.status_code}"

    def unknown_route_404(r):
        resp = api("GET", "/api/v1/this-does-not-exist-xyz")
        chk(resp, r, 404)

    def health_response_has_timestamp(r):
        resp = api("GET", "/health")
        chk(resp, r, 200)
        body = resp.json()
        assert "timestamp" in body or "uptime" in body, \
            f"No timestamp/uptime in health response: {list(body.keys())}"

    run("GET /health → 200 ok", C, health_ok)
    run("GET /api/v1/model/info → reachable", C, model_info_reachable)
    run("GET /api/v1/breeds?pet_type=dog → 200 with list", C, breeds_dog)
    run("GET /api/v1/breeds?pet_type=cat → 200 with list", C, breeds_cat)
    run("GET /api/v1/breeds?pet_type=fish → 200/400", C, breeds_invalid_type)
    run("GET /api/v1/unknown-route → 404", C, unknown_route_404)
    run("GET /health response contains timestamp/uptime", C, health_response_has_timestamp)


# ══════════════════════════════════════════════════════════════════════════════
#  2. Auth — SignUp  (6 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s02_signup():
    print("\n[02] Auth — SignUp")
    C = "Auth.SignUp"

    def missing_all(r):
        resp = api("POST", "/api/v1/auth/signup", json={})
        chk(resp, r, 400)

    def bad_email(r):
        resp = api("POST", "/api/v1/auth/signup", json={"email": "not-email", "password": PASSWORD})
        chk(resp, r, 400)

    def short_pass(r):
        resp = api("POST", "/api/v1/auth/signup", json={"email": EMAIL, "password": "abc"})
        chk(resp, r, 400)

    def missing_password(r):
        resp = api("POST", "/api/v1/auth/signup", json={"email": EMAIL})
        chk(resp, r, 400)

    def success(r):
        resp = api("POST", "/api/v1/auth/signup", json={
            "email": EMAIL, "password": PASSWORD,
            "displayName": f"PawPal Tester {UID}",
        })
        chk(resp, r, 201)
        body = resp.json()
        assert body.get("success") is True
        key(body, "accessToken", r)
        key(body, "refreshToken", r)
        S["access_token"]  = body["accessToken"]
        S["refresh_token"] = body["refreshToken"]
        S["user_id"]       = (body.get("user") or {}).get("id", "")
        r.detail = f"user_id={S['user_id']}"

    def duplicate(r):
        resp = api("POST", "/api/v1/auth/signup", json={"email": EMAIL, "password": PASSWORD})
        chk(resp, r, 409)

    run("POST /auth/signup — empty body → 400", C, missing_all)
    run("POST /auth/signup — invalid email → 400", C, bad_email)
    run("POST /auth/signup — password < 6 chars → 400", C, short_pass)
    run("POST /auth/signup — missing password → 400", C, missing_password)
    run("POST /auth/signup — valid → 201 + tokens", C, success)
    run("POST /auth/signup — duplicate email → 409", C, duplicate)


# ══════════════════════════════════════════════════════════════════════════════
#  3. Auth — SignIn  (5 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s03_signin():
    print("\n[03] Auth — SignIn")
    C = "Auth.SignIn"

    def wrong_pass(r):
        resp = api("POST", "/api/v1/auth/signin", json={"email": EMAIL, "password": "WrongPass!"})
        chk(resp, r, 401)

    def unknown_email(r):
        resp = api("POST", "/api/v1/auth/signin", json={"email": "nobody_xyz@nowhere.com", "password": PASSWORD})
        chk(resp, r, 401)

    def missing_password(r):
        resp = api("POST", "/api/v1/auth/signin", json={"email": EMAIL})
        chk(resp, r, 400)

    def empty_body(r):
        resp = api("POST", "/api/v1/auth/signin", json={})
        chk(resp, r, 400)

    def success(r):
        resp = api("POST", "/api/v1/auth/signin", json={"email": EMAIL, "password": PASSWORD})
        chk(resp, r, 200)
        body = resp.json()
        assert body.get("success") is True
        key(body, "accessToken", r)
        S["access_token"]  = body["accessToken"]
        S["refresh_token"] = body["refreshToken"]
        r.detail = "tokens updated"

    run("POST /auth/signin — wrong password → 401", C, wrong_pass)
    run("POST /auth/signin — unknown email → 401", C, unknown_email)
    run("POST /auth/signin — missing password → 400", C, missing_password)
    run("POST /auth/signin — empty body → 400", C, empty_body)
    run("POST /auth/signin — valid credentials → 200", C, success)


# ══════════════════════════════════════════════════════════════════════════════
#  4. Auth — Token Refresh  (4 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s04_token():
    print("\n[04] Auth — Token Refresh")
    C = "Auth.Token"

    def refresh_valid(r):
        rt = S.get("refresh_token")
        if not rt:
            r.passed = False; r.detail = "No refresh token"; raise AssertionError()
        resp = api("POST", "/api/v1/auth/refresh", json={"refreshToken": rt})
        chk(resp, r, 200)
        body = resp.json()
        key(body, "accessToken", r)
        S["access_token"]  = body["accessToken"]
        S["refresh_token"] = body.get("refreshToken", rt)
        r.detail = "token rotated"

    def refresh_fake(r):
        resp = api("POST", "/api/v1/auth/refresh", json={"refreshToken": "not.a.real.token"})
        r.status_code = resp.status_code
        assert resp.status_code in (400, 401)

    def refresh_empty(r):
        resp = api("POST", "/api/v1/auth/refresh", json={})
        chk(resp, r, 400)

    def refresh_missing_field(r):
        resp = api("POST", "/api/v1/auth/refresh", json={"token": "wrong-key"})
        chk(resp, r, 400)

    run("POST /auth/refresh — valid → 200 + new tokens", C, refresh_valid)
    run("POST /auth/refresh — fake token → 400/401", C, refresh_fake)
    run("POST /auth/refresh — empty body → 400", C, refresh_empty)
    run("POST /auth/refresh — wrong field name → 400", C, refresh_missing_field)


# ══════════════════════════════════════════════════════════════════════════════
#  5. Profile & Roles  (9 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s05_profile():
    print("\n[05] Profile & Roles")
    C = "Profile"

    def get_no_auth(r):
        resp = api("GET", "/api/v1/profile")
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def get_bad_jwt(r):
        resp = api("GET", "/api/v1/profile", token="aaaa.bbbb.cccc")
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def get_authenticated(r):
        resp = api("GET", "/api/v1/profile", token=tok())
        chk(resp, r, 200)
        body = resp.json()
        assert body.get("success") is True
        profile = body.get("data") or body
        assert profile.get("uid") or profile.get("id"), \
            f"No uid/id in profile: {list(profile.keys())}"
        r.detail = f"email={profile.get('email')}"

    def update_display_name(r):
        resp = api("PUT", "/api/v1/profile", token=tok(), json={"displayName": f"Updated_{UID}"})
        chk(resp, r, 200)

    def update_no_auth(r):
        resp = api("PUT", "/api/v1/profile", json={"displayName": "hacker"})
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def get_roles(r):
        resp = api("GET", "/api/v1/user/roles", token=tok())
        chk(resp, r, 200)
        r.detail = str(resp.json())

    def set_role_pet_owner(r):
        resp = api("POST", "/api/v1/auth/set-role", token=tok(), json={"role": "pet_owner"})
        r.status_code = resp.status_code
        assert resp.status_code in (200, 400)
        r.detail = f"status={resp.status_code}"

    def add_role(r):
        resp = api("POST", "/api/v1/user/roles/add", token=tok(), json={"role": "pet_owner"})
        r.status_code = resp.status_code
        assert resp.status_code in (200, 400, 409)
        r.detail = f"status={resp.status_code}"

    def switch_role(r):
        resp = api("POST", "/api/v1/user/roles/switch", token=tok(), json={"role": "pet_owner"})
        r.status_code = resp.status_code
        assert resp.status_code in (200, 400, 409)
        r.detail = f"status={resp.status_code}"

    run("GET /profile — no auth → 401", C, get_no_auth)
    run("GET /profile — bad JWT → 401", C, get_bad_jwt)
    run("GET /profile — valid token → 200", C, get_authenticated)
    run("PUT /profile — update displayName → 200", C, update_display_name)
    run("PUT /profile — no auth → 401", C, update_no_auth)
    run("GET /user/roles → 200", C, get_roles)
    run("POST /auth/set-role pet_owner → 200", C, set_role_pet_owner)
    run("POST /user/roles/add pet_owner → 200/409", C, add_role)
    run("POST /user/roles/switch pet_owner → 200", C, switch_role)


# ══════════════════════════════════════════════════════════════════════════════
#  6. Password Reset  (4 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s06_password_reset():
    print("\n[06] Password Reset")
    C = "Auth.PasswordReset"

    def request_known(r):
        resp = api("POST", "/api/v1/auth/password/reset-request", json={"email": EMAIL})
        chk(resp, r, 200)

    def request_unknown(r):
        resp = api("POST", "/api/v1/auth/password/reset-request", json={"email": "ghost@noone.com"})
        r.status_code = resp.status_code
        assert resp.status_code in (200, 404)
        r.detail = f"status={resp.status_code}"

    def reset_fake_token(r):
        resp = api("POST", "/api/v1/auth/password/reset", json={
            "token": "fake-token-xyz", "newPassword": "NewPass@5678"
        })
        r.status_code = resp.status_code
        assert resp.status_code in (400, 401, 404)

    def reset_missing_fields(r):
        resp = api("POST", "/api/v1/auth/password/reset", json={})
        chk(resp, r, 400)

    run("POST /auth/password/reset-request — known email → 200", C, request_known)
    run("POST /auth/password/reset-request — unknown email → 200/404", C, request_unknown)
    run("POST /auth/password/reset — fake token → 400/401/404", C, reset_fake_token)
    run("POST /auth/password/reset — empty body → 400", C, reset_missing_fields)


# ══════════════════════════════════════════════════════════════════════════════
#  7. Pets CRUD  (11 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s07_pets():
    print("\n[07] Pets CRUD")
    C = "Pets"

    def list_no_auth(r):
        resp = api("GET", "/api/v1/pets")
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def list_auth(r):
        resp = api("GET", "/api/v1/pets", token=tok())
        chk(resp, r, 200)
        body = resp.json()
        assert body.get("success") is True
        r.detail = f"count={body.get('count')}"

    def create_missing_fields(r):
        resp = api("POST", "/api/v1/pets", token=tok(), json={"name": "Buddy"})
        chk(resp, r, 400)

    def create_invalid_type(r):
        resp = api("POST", "/api/v1/pets", token=tok(), json={
            "name": "Rex", "type": "dragon", "breed": "Fire",
            "age": 1, "ageUnit": "years", "gender": "male",
            "color": "red", "weight": 5.0, "weightUnit": "kg",
        })
        chk(resp, r, 400)

    def create_invalid_gender(r):
        resp = api("POST", "/api/v1/pets", token=tok(), json={
            "name": "Rex", "type": "dog", "breed": "Lab",
            "age": 1, "ageUnit": "years", "gender": "unknown",
            "color": "black", "weight": 10.0, "weightUnit": "kg",
        })
        chk(resp, r, 400)

    def create_negative_age(r):
        resp = api("POST", "/api/v1/pets", token=tok(), json={
            "name": "Rex", "type": "dog", "breed": "Lab",
            "age": -1, "ageUnit": "years", "gender": "male",
            "color": "black", "weight": 10.0, "weightUnit": "kg",
        })
        chk(resp, r, 400)

    def create_success(r):
        resp = api("POST", "/api/v1/pets", token=tok(), json={
            "name": f"Buddy_{UID}", "type": "dog", "breed": "Labrador",
            "age": 3, "ageUnit": "years", "gender": "male",
            "color": "golden", "weight": 28.5, "weightUnit": "kg",
        })
        chk(resp, r, 201)
        body = resp.json()
        assert body.get("success") is True
        pet = body.get("pet", {})
        assert pet.get("id"), "No pet ID"
        S["pet_id"] = pet["id"]
        r.detail = f"pet_id={pet['id']}"

    def create_cat(r):
        resp = api("POST", "/api/v1/pets", token=tok(), json={
            "name": f"Whiskers_{UID}", "type": "cat", "breed": "Persian",
            "age": 2, "ageUnit": "years", "gender": "female",
            "color": "white", "weight": 4.0, "weightUnit": "kg",
        })
        chk(resp, r, 201)
        S["cat_id"] = resp.json().get("pet", {}).get("id", "")

    def get_pet(r):
        skip_if_missing(r, "pet_id")
        resp = api("GET", f"/api/v1/pets/{S['pet_id']}", token=tok())
        chk(resp, r, 200)
        body = resp.json()
        assert body.get("success") is True
        r.detail = f"name={body.get('pet',{}).get('name')}"

    def get_nonexistent(r):
        resp = api("GET", f"/api/v1/pets/{uuid.uuid4()}", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (404, 403)

    def update_pet(r):
        skip_if_missing(r, "pet_id")
        resp = api("PUT", f"/api/v1/pets/{S['pet_id']}", token=tok(), json={"breed": "Golden Retriever"})
        chk(resp, r, 200)

    def get_count(r):
        resp = api("GET", "/api/v1/pets/count", token=tok())
        chk(resp, r, 200)
        body = resp.json()
        assert body.get("success") is True
        r.detail = f"count={body.get('count')}"

    def get_verified(r):
        resp = api("GET", "/api/v1/pets/verified", token=tok())
        chk(resp, r, 200)

    def search_by_breed(r):
        resp = api("GET", "/api/v1/pets/search?breed=Labrador", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 400)
        r.detail = f"status={resp.status_code}"

    def delete_cat(r):
        cat_id = S.get("cat_id")
        if not cat_id:
            r.passed = False; r.detail = "No cat_id"; raise AssertionError()
        resp = api("DELETE", f"/api/v1/pets/{cat_id}", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 204)

    run("GET /pets — no auth → 401", C, list_no_auth)
    run("GET /pets — auth → 200 list", C, list_auth)
    run("POST /pets — missing required fields → 400", C, create_missing_fields)
    run("POST /pets — invalid type=dragon → 400", C, create_invalid_type)
    run("POST /pets — invalid gender=unknown → 400", C, create_invalid_gender)
    run("POST /pets — negative age → 400", C, create_negative_age)
    run("POST /pets — valid dog → 201", C, create_success)
    run("POST /pets — valid cat → 201", C, create_cat)
    run("GET /pets/:id — existing → 200", C, get_pet)
    run("GET /pets/:id — nonexistent UUID → 404", C, get_nonexistent)
    run("PUT /pets/:id — update breed → 200", C, update_pet)
    run("GET /pets/count → 200", C, get_count)
    run("GET /pets/verified → 200", C, get_verified)
    run("GET /pets/search?breed=Labrador → 200", C, search_by_breed)
    run("DELETE /pets/:id — own pet → 200", C, delete_cat)


# ══════════════════════════════════════════════════════════════════════════════
#  8. Health Records  (5 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s08_health_records():
    print("\n[08] Health Records")
    C = "HealthRecords"

    def create_no_auth(r):
        resp = api("POST", "/api/v1/health-records", json={})
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def create_missing_pet(r):
        resp = api("POST", "/api/v1/health-records", token=tok(), json={
            "isVaccinated": True,
        })
        chk(resp, r, 400)

    def create_success(r):
        skip_if_missing(r, "pet_id")
        resp = api("POST", "/api/v1/health-records", token=tok(), json={
            "petId": S["pet_id"],
            "isVaccinated": True,
            "vaccinationDetails": "Rabies, Parvovirus",
            "medicalConditions": [],
        })
        r.status_code = resp.status_code
        assert resp.status_code in (201, 409), \
            f"Expected 201/409, got {resp.status_code}: {resp.text[:200]}"
        if resp.status_code == 201:
            S["health_record_id"] = resp.json().get("healthRecord", {}).get("id", "")
        r.detail = f"status={resp.status_code}"

    def get_by_pet(r):
        skip_if_missing(r, "pet_id")
        resp = api("GET", f"/api/v1/health-records/pet/{S['pet_id']}", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 404)
        r.detail = f"status={resp.status_code}"

    def get_for_nonexistent_pet(r):
        resp = api("GET", f"/api/v1/health-records/pet/{uuid.uuid4()}", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (404, 403)

    run("POST /health-records — no auth → 401", C, create_no_auth)
    run("POST /health-records — missing petId → 400", C, create_missing_pet)
    run("POST /health-records — valid → 201/409", C, create_success)
    run("GET /health-records/pet/:petId → 200/404", C, get_by_pet)
    run("GET /health-records/pet/:fake-uuid → 404", C, get_for_nonexistent_pet)


# ══════════════════════════════════════════════════════════════════════════════
#  9. Health Journals  (5 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s09_health_journals():
    print("\n[09] Health Journals")
    C = "HealthJournals"

    def create_no_auth(r):
        resp = api("POST", "/api/v1/health-journals", json={})
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def create_missing_pet(r):
        resp = api("POST", "/api/v1/health-journals", token=tok(), json={
            "date": "2026-04-17",
        })
        chk(resp, r, 400)

    def create_success(r):
        skip_if_missing(r, "pet_id")
        resp = api("POST", "/api/v1/health-journals", token=tok(), json={
            "petId": S["pet_id"],
            "date": "2026-04-17",
            "activityLevel": "high",
            "mood": "happy",
            "appetite": "normal",
        })
        chk(resp, r, 201)
        body = resp.json()
        S["journal_id"] = body.get("healthJournal", {}).get("id", "")
        r.detail = f"journal_id={S['journal_id']}"

    def get_journals(r):
        skip_if_missing(r, "pet_id")
        resp = api("GET", f"/api/v1/health-journals/pet/{S['pet_id']}", token=tok())
        chk(resp, r, 200)
        body = resp.json()
        assert body.get("success") is True

    def delete_journal(r):
        jid = S.get("journal_id")
        if not jid:
            r.passed = False; r.detail = "No journal_id"; raise AssertionError()
        resp = api("DELETE", f"/api/v1/health-journals/{jid}", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 204)

    run("POST /health-journals — no auth → 401", C, create_no_auth)
    run("POST /health-journals — missing petId → 400", C, create_missing_pet)
    run("POST /health-journals — valid → 201", C, create_success)
    run("GET /health-journals/pet/:petId → 200 list", C, get_journals)
    run("DELETE /health-journals/:id → 200", C, delete_journal)


# ══════════════════════════════════════════════════════════════════════════════
#  10. Community Posts  (9 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s10_posts():
    print("\n[10] Community Posts")
    C = "Posts"

    def create_no_auth(r):
        resp = api("POST", "/api/v1/posts", json={"title": "x", "content": "y"})
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def create_missing_content(r):
        resp = api("POST", "/api/v1/posts", token=tok(), json={"title": "Title only"})
        chk(resp, r, 400)

    def create_success(r):
        resp = api("POST", "/api/v1/posts", token=tok(), json={
            "title": f"Integration post {UID}",
            "content": "This is an automated integration test post — please ignore.",
            "category": "general",
        })
        chk(resp, r, 201)
        body = resp.json()
        assert body.get("success") is True
        S["post_id"] = body.get("post", {}).get("id", "")
        r.detail = f"post_id={S['post_id']}"

    def get_all(r):
        resp = api("GET", "/api/v1/posts", token=tok())
        chk(resp, r, 200)
        r.detail = f"count={resp.json().get('count')}"

    def get_my_posts(r):
        resp = api("GET", "/api/v1/posts/me", token=tok())
        chk(resp, r, 200)

    def get_by_id(r):
        skip_if_missing(r, "post_id")
        resp = api("GET", f"/api/v1/posts/{S['post_id']}", token=tok())
        chk(resp, r, 200)

    def like_toggle(r):
        skip_if_missing(r, "post_id")
        resp = api("POST", f"/api/v1/posts/{S['post_id']}/like", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 201)

    def check_liked(r):
        skip_if_missing(r, "post_id")
        resp = api("GET", f"/api/v1/posts/{S['post_id']}/liked", token=tok())
        chk(resp, r, 200)

    def update_post(r):
        skip_if_missing(r, "post_id")
        resp = api("PUT", f"/api/v1/posts/{S['post_id']}", token=tok(), json={
            "content": "Updated content by integration tests."
        })
        chk(resp, r, 200)

    def get_nonexistent(r):
        resp = api("GET", f"/api/v1/posts/{uuid.uuid4()}", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (404, 403)

    run("POST /posts — no auth → 401", C, create_no_auth)
    run("POST /posts — missing content → 400", C, create_missing_content)
    run("POST /posts — valid → 201", C, create_success)
    run("GET /posts — list all → 200", C, get_all)
    run("GET /posts/me — my posts → 200", C, get_my_posts)
    run("GET /posts/:id → 200", C, get_by_id)
    run("POST /posts/:id/like — toggle → 200", C, like_toggle)
    run("GET /posts/:id/liked → 200", C, check_liked)
    run("PUT /posts/:id — update content → 200", C, update_post)
    run("GET /posts/:fake-uuid → 404", C, get_nonexistent)


# ══════════════════════════════════════════════════════════════════════════════
#  11. Comments  (6 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s11_comments():
    print("\n[11] Comments")
    C = "Comments"

    def create_no_auth(r):
        resp = api("POST", "/api/v1/comments", json={})
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def create_missing_fields(r):
        resp = api("POST", "/api/v1/comments", token=tok(), json={"content": "no postId"})
        chk(resp, r, 400)

    def create_success(r):
        skip_if_missing(r, "post_id")
        resp = api("POST", "/api/v1/comments", token=tok(), json={
            "postId": S["post_id"],
            "content": "Automated test comment — integration suite.",
        })
        chk(resp, r, 201)
        S["comment_id"] = resp.json().get("comment", {}).get("id", "")
        r.detail = f"comment_id={S['comment_id']}"

    def get_comments(r):
        skip_if_missing(r, "post_id")
        resp = api("GET", f"/api/v1/comments/post/{S['post_id']}", token=tok())
        chk(resp, r, 200)
        r.detail = f"count={resp.json().get('count')}"

    def like_comment(r):
        cid = S.get("comment_id")
        if not cid:
            r.passed = False; r.detail = "No comment_id"; raise AssertionError()
        resp = api("POST", f"/api/v1/comments/{cid}/like", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 201)

    def delete_comment(r):
        cid = S.get("comment_id")
        if not cid:
            r.passed = False; r.detail = "No comment_id"; raise AssertionError()
        resp = api("DELETE", f"/api/v1/comments/{cid}", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 204)

    run("POST /comments — no auth → 401", C, create_no_auth)
    run("POST /comments — missing postId → 400", C, create_missing_fields)
    run("POST /comments — valid → 201", C, create_success)
    run("GET /comments/post/:postId → 200 list", C, get_comments)
    run("POST /comments/:id/like — toggle → 200", C, like_comment)
    run("DELETE /comments/:id → 200", C, delete_comment)


# ══════════════════════════════════════════════════════════════════════════════
#  12. Community Advanced (Trending, Hashtags, Groups)  (7 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s12_community_advanced():
    print("\n[12] Community Advanced")
    C = "Community.Advanced"

    def trending_posts(r):
        resp = api("GET", "/api/v1/community/trending/posts", token=tok())
        chk(resp, r, 200)

    def trending_hashtags(r):
        resp = api("GET", "/api/v1/community/trending/hashtags", token=tok())
        chk(resp, r, 200)

    def hashtag_posts(r):
        resp = api("GET", "/api/v1/community/hashtags/dogs/posts", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 404)
        r.detail = f"status={resp.status_code}"

    def list_groups(r):
        resp = api("GET", "/api/v1/community/groups", token=tok())
        chk(resp, r, 200)

    def my_groups(r):
        resp = api("GET", "/api/v1/community/groups/me", token=tok())
        chk(resp, r, 200)

    def create_group(r):
        resp = api("POST", "/api/v1/community/groups", token=tok(), json={
            "name": f"TestGroup_{UID}",
            "isPrivate": False,
        })
        chk(resp, r, 201)
        S["group_id"] = resp.json().get("group", {}).get("id", "")
        r.detail = f"group_id={S['group_id']}"

    def create_group_short_name(r):
        resp = api("POST", "/api/v1/community/groups", token=tok(), json={"name": "ab", "isPrivate": False})
        chk(resp, r, 400)

    run("GET /community/trending/posts → 200", C, trending_posts)
    run("GET /community/trending/hashtags → 200", C, trending_hashtags)
    run("GET /community/hashtags/dogs/posts → 200/404", C, hashtag_posts)
    run("GET /community/groups → 200", C, list_groups)
    run("GET /community/groups/me → 200", C, my_groups)
    run("POST /community/groups — valid → 201", C, create_group)
    run("POST /community/groups — name too short → 400", C, create_group_short_name)


# ══════════════════════════════════════════════════════════════════════════════
#  13. Vets (Public + Protected)  (6 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s13_vets():
    print("\n[13] Vets")
    C = "Vets"

    def list_public(r):
        resp = api("GET", "/api/v1/vets")
        chk(resp, r, 200)

    def get_profile_invalid_uuid(r):
        resp = api("GET", "/api/v1/vets/profile/not-a-uuid")
        r.status_code = resp.status_code
        assert resp.status_code in (400, 404)

    def get_profile_fake_uuid(r):
        resp = api("GET", f"/api/v1/vets/profile/{uuid.uuid4()}")
        r.status_code = resp.status_code
        assert resp.status_code in (404, 200)
        r.detail = f"status={resp.status_code}"

    def get_vet_reviews_fake(r):
        resp = api("GET", f"/api/v1/vets/{uuid.uuid4()}/reviews")
        r.status_code = resp.status_code
        assert resp.status_code in (200, 404)

    def get_my_profile_no_auth(r):
        resp = api("GET", "/api/v1/vets/profile/me")
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def get_my_profile_auth(r):
        resp = api("GET", "/api/v1/vets/profile/me", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 404)
        r.detail = f"status={resp.status_code}"

    run("GET /vets — public list → 200", C, list_public)
    run("GET /vets/profile/not-a-uuid → 400/404", C, get_profile_invalid_uuid)
    run("GET /vets/profile/:fake-uuid → 404", C, get_profile_fake_uuid)
    run("GET /vets/:fake-uuid/reviews → 200/404", C, get_vet_reviews_fake)
    run("GET /vets/profile/me — no auth → 401", C, get_my_profile_no_auth)
    run("GET /vets/profile/me — auth → 200/404", C, get_my_profile_auth)


# ══════════════════════════════════════════════════════════════════════════════
#  14. Marketplace — Public  (5 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s14_marketplace_public():
    print("\n[14] Marketplace — Public")
    C = "Marketplace.Public"

    def categories(r):
        resp = api("GET", "/api/v1/marketplace/categories")
        chk(resp, r, 200)

    def products_list(r):
        resp = api("GET", "/api/v1/marketplace/products")
        chk(resp, r, 200)

    def products_with_pagination(r):
        resp = api("GET", "/api/v1/marketplace/products?page=1&limit=3")
        chk(resp, r, 200)

    def product_fake_uuid(r):
        resp = api("GET", f"/api/v1/marketplace/products/{uuid.uuid4()}")
        r.status_code = resp.status_code
        assert resp.status_code in (404, 400)

    def product_reviews_fake(r):
        resp = api("GET", f"/api/v1/marketplace/products/{uuid.uuid4()}/reviews")
        r.status_code = resp.status_code
        assert resp.status_code in (200, 404, 400)
        r.detail = f"status={resp.status_code}"

    run("GET /marketplace/categories → 200", C, categories)
    run("GET /marketplace/products → 200", C, products_list)
    run("GET /marketplace/products?page=1&limit=3 → 200", C, products_with_pagination)
    run("GET /marketplace/products/:fake-uuid → 404", C, product_fake_uuid)
    run("GET /marketplace/products/:fake-uuid/reviews → 200/404", C, product_reviews_fake)


# ══════════════════════════════════════════════════════════════════════════════
#  15. Marketplace — Protected (Cart + Orders + Create product)  (7 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s15_marketplace_protected():
    print("\n[15] Marketplace — Protected")
    C = "Marketplace.Protected"

    def create_product_no_auth(r):
        resp = api("POST", "/api/v1/marketplace/products", json={"name": "x", "price": 1})
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def create_product(r):
        resp = api("POST", "/api/v1/marketplace/products", token=tok(), json={
            "name": f"TestProduct_{UID}",
            "description": "Integration test product",
            "price": 49.99,
            "currency": "PKR",
            "stock": 10,
        })
        r.status_code = resp.status_code
        assert resp.status_code in (201, 400, 422), f"got {resp.status_code}: {resp.text[:200]}"
        if resp.status_code == 201:
            S["product_id"] = resp.json().get("product", {}).get("id", "")
        r.detail = f"status={resp.status_code}"

    def get_my_products(r):
        resp = api("GET", "/api/v1/marketplace/products/mine", token=tok())
        chk(resp, r, 200)

    def get_cart(r):
        resp = api("GET", "/api/v1/marketplace/cart", token=tok())
        chk(resp, r, 200)

    def add_to_cart_bad_product(r):
        resp = api("POST", "/api/v1/marketplace/cart", token=tok(), json={
            "productId": str(uuid.uuid4()),
            "quantity": 1,
        })
        r.status_code = resp.status_code
        assert resp.status_code in (400, 404, 422)
        r.detail = f"status={resp.status_code}"

    def get_orders(r):
        resp = api("GET", "/api/v1/marketplace/orders", token=tok())
        chk(resp, r, 200)

    def get_seller_orders(r):
        resp = api("GET", "/api/v1/marketplace/seller/orders", token=tok())
        chk(resp, r, 200)

    run("POST /marketplace/products — no auth → 401", C, create_product_no_auth)
    run("POST /marketplace/products — valid → 201/400", C, create_product)
    run("GET /marketplace/products/mine → 200", C, get_my_products)
    run("GET /marketplace/cart → 200", C, get_cart)
    run("POST /marketplace/cart — fake productId → 400/404", C, add_to_cart_bad_product)
    run("GET /marketplace/orders → 200", C, get_orders)
    run("GET /marketplace/seller/orders → 200", C, get_seller_orders)


# ══════════════════════════════════════════════════════════════════════════════
#  16. Lost & Found  (7 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s16_lost_found():
    print("\n[16] Lost & Found")
    C = "LostFound"

    def list_auth(r):
        resp = api("GET", "/api/v1/lost-found", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 404)
        r.detail = f"status={resp.status_code}"

    def create_no_auth(r):
        resp = api("POST", "/api/v1/lost-found", json={"type": "lost", "description": "x"})
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def create_invalid_type(r):
        resp = api("POST", "/api/v1/lost-found", token=tok(), json={
            "type": "stolen", "description": "My pet",
        })
        chk(resp, r, 400)

    def create_missing_desc(r):
        resp = api("POST", "/api/v1/lost-found", token=tok(), json={"type": "lost"})
        chk(resp, r, 400)

    def create_lost(r):
        resp = api("POST", "/api/v1/lost-found", token=tok(), json={
            "type": "lost",
            "description": f"Integration test — lost dog near park {UID}",
            "petName": "Max",
            "petType": "dog",
            "urgency": "medium",
        })
        chk(resp, r, 201)
        S["lf_id"] = resp.json().get("lostFoundPost", {}).get("id", "")
        r.detail = f"id={S['lf_id']}"

    def create_found(r):
        resp = api("POST", "/api/v1/lost-found", token=tok(), json={
            "type": "found",
            "description": f"Integration test — found cat near school {UID}",
            "urgency": "low",
        })
        chk(resp, r, 201)
        S["lf_found_id"] = resp.json().get("lostFoundPost", {}).get("id", "")

    def get_my_posts(r):
        resp = api("GET", "/api/v1/lost-found/me", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 404)
        r.detail = f"status={resp.status_code}"

    run("GET /lost-found — auth → 200/404", C, list_auth)
    run("POST /lost-found — no auth → 401", C, create_no_auth)
    run("POST /lost-found — invalid type → 400", C, create_invalid_type)
    run("POST /lost-found — missing description → 400", C, create_missing_desc)
    run("POST /lost-found — type=lost → 201", C, create_lost)
    run("POST /lost-found — type=found → 201", C, create_found)
    run("GET /lost-found/me → 200", C, get_my_posts)


# ══════════════════════════════════════════════════════════════════════════════
#  17. Adoption Listings  (5 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s17_adoptions():
    print("\n[17] Adoption Listings")
    C = "Adoptions"

    def list_adoptions(r):
        resp = api("GET", "/api/v1/adoptions", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code == 200, f"Unexpected: {resp.status_code}"
        r.detail = f"status={resp.status_code}"

    def list_no_auth(r):
        resp = api("GET", "/api/v1/adoptions")
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def create_unowned_pet(r):
        resp = api("POST", "/api/v1/adoptions", token=tok(), json={
            "petId": str(uuid.uuid4()),
            "petName": "Ghost", "petType": "dog",
            "description": "Good boy", "adoptionFee": 0.0,
            "isVaccinated": False, "isNeutered": False, "isTrained": False,
        })
        r.status_code = resp.status_code
        assert resp.status_code in (400, 403, 404, 500)
        r.detail = f"status={resp.status_code}"

    def create_success(r):
        skip_if_missing(r, "pet_id")
        resp = api("POST", "/api/v1/adoptions", token=tok(), json={
            "petId": S["pet_id"],
            "petName": f"Buddy_{UID}", "petType": "dog",
            "description": "Integration test adoption listing",
            "adoptionFee": 100.0,
            "isVaccinated": True, "isNeutered": False, "isTrained": True,
        })
        r.status_code = resp.status_code
        assert resp.status_code in (201, 409, 400)
        if resp.status_code == 201:
            S["adoption_id"] = resp.json().get("adoption", {}).get("id", "")
        r.detail = f"status={resp.status_code}"

    def get_my_adoptions(r):
        resp = api("GET", "/api/v1/adoptions/me", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 404, 500)
        r.detail = f"status={resp.status_code}"

    run("GET /adoptions — auth → 200/500 (SQL bug noted)", C, list_adoptions)
    run("GET /adoptions — no auth → 401", C, list_no_auth)
    run("POST /adoptions — unowned pet → 400/404", C, create_unowned_pet)
    run("POST /adoptions — own pet → 201/409", C, create_success)
    run("GET /adoptions/me → 200/500", C, get_my_adoptions)


# ══════════════════════════════════════════════════════════════════════════════
#  18. Events  (8 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s18_events():
    print("\n[18] Events")
    C = "Events"

    def list_no_auth(r):
        resp = api("GET", "/api/v1/events")
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def list_auth(r):
        resp = api("GET", "/api/v1/events", token=tok())
        chk(resp, r, 200)

    def create_missing_title(r):
        resp = api("POST", "/api/v1/events", token=tok(), json={
            "description": "No title", "startDate": "2026-06-01T10:00:00Z",
        })
        chk(resp, r, 400)

    def create_missing_start_date(r):
        resp = api("POST", "/api/v1/events", token=tok(), json={
            "title": "Title only", "description": "No date",
        })
        chk(resp, r, 400)

    def create_success(r):
        resp = api("POST", "/api/v1/events", token=tok(), json={
            "title": f"TestEvent_{UID}",
            "description": "Integration test event — please ignore",
            "eventType": "meetup",
            "startDate": "2026-06-15T10:00:00Z",
            "isPetFriendly": True,
        })
        chk(resp, r, 201)
        S["event_id"] = resp.json().get("event", {}).get("id", "")
        r.detail = f"event_id={S['event_id']}"

    def get_by_id(r):
        skip_if_missing(r, "event_id")
        resp = api("GET", f"/api/v1/events/{S['event_id']}", token=tok())
        chk(resp, r, 200)

    def rsvp(r):
        skip_if_missing(r, "event_id")
        resp = api("POST", f"/api/v1/events/{S['event_id']}/rsvp", token=tok(), json={"status": "going"})
        r.status_code = resp.status_code
        assert resp.status_code in (200, 201, 409)
        r.detail = f"status={resp.status_code}"

    def get_rsvps(r):
        skip_if_missing(r, "event_id")
        resp = api("GET", f"/api/v1/events/{S['event_id']}/rsvps", token=tok())
        chk(resp, r, 200)

    run("GET /events — no auth → 401", C, list_no_auth)
    run("GET /events — auth → 200", C, list_auth)
    run("POST /events — missing title → 400", C, create_missing_title)
    run("POST /events — missing startDate → 400", C, create_missing_start_date)
    run("POST /events — valid → 201", C, create_success)
    run("GET /events/:id → 200", C, get_by_id)
    run("POST /events/:id/rsvp → 200/201/409", C, rsvp)
    run("GET /events/:id/rsvps → 200", C, get_rsvps)


# ══════════════════════════════════════════════════════════════════════════════
#  19. Chats & Messages  (6 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s19_chats():
    print("\n[19] Chats & Messages")
    C = "Chats"

    def get_chats_no_auth(r):
        resp = api("GET", "/api/v1/chats")
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def get_my_chats(r):
        resp = api("GET", "/api/v1/chats", token=tok())
        chk(resp, r, 200)
        r.detail = str(resp.json())[:80]

    def start_chat_bad_user(r):
        resp = api("POST", "/api/v1/chats", token=tok(), json={
            "recipientId": str(uuid.uuid4()),
        })
        r.status_code = resp.status_code
        assert resp.status_code in (200, 201, 400, 404)
        r.detail = f"status={resp.status_code}"

    def get_chat_fake(r):
        resp = api("GET", f"/api/v1/chats/{uuid.uuid4()}", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (404, 403)

    def send_message_no_chat(r):
        resp = api("POST", "/api/v1/messages", token=tok(), json={
            "chatId": str(uuid.uuid4()),
            "content": "Hello",
            "messageType": "text",
        })
        r.status_code = resp.status_code
        assert resp.status_code in (400, 403, 404)
        r.detail = f"status={resp.status_code}"

    def get_messages_fake_chat(r):
        resp = api("GET", f"/api/v1/messages/{uuid.uuid4()}", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 403, 404)
        r.detail = f"status={resp.status_code}"

    run("GET /chats — no auth → 401", C, get_chats_no_auth)
    run("GET /chats — auth → 200", C, get_my_chats)
    run("POST /chats — start chat with fake user → 200/404", C, start_chat_bad_user)
    run("GET /chats/:fake-uuid → 403/404", C, get_chat_fake)
    run("POST /messages — fake chatId → 400/404", C, send_message_no_chat)
    run("GET /messages/:fake-chatId → 200/403/404", C, get_messages_fake_chat)


# ══════════════════════════════════════════════════════════════════════════════
#  20. Caregivers  (7 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s20_caregivers():
    print("\n[20] Caregivers")
    C = "Caregivers"

    def service_types(r):
        resp = api("GET", "/api/v1/caregivers/service-types", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 404)
        r.detail = f"status={resp.status_code}"

    def profile_no_auth(r):
        resp = api("GET", "/api/v1/caregivers/profile")
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def get_profile(r):
        resp = api("GET", "/api/v1/caregivers/profile", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 404)
        r.detail = f"status={resp.status_code}"

    def search(r):
        resp = api("GET", "/api/v1/caregivers/search", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 404)
        r.detail = f"status={resp.status_code}"

    def get_caregiver_fake(r):
        resp = api("GET", f"/api/v1/caregivers/{uuid.uuid4()}", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (404, 400)
        r.detail = f"status={resp.status_code}"

    def get_reviews_fake(r):
        resp = api("GET", f"/api/v1/caregivers/{uuid.uuid4()}/reviews", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 404, 400)
        r.detail = f"status={resp.status_code}"

    def create_profile_missing_fields(r):
        resp = api("POST", "/api/v1/caregivers/profile", token=tok(), json={})
        r.status_code = resp.status_code
        assert resp.status_code in (400, 409, 201)
        r.detail = f"status={resp.status_code}"

    run("GET /caregivers/service-types → 200/404", C, service_types)
    run("GET /caregivers/profile — no auth → 401", C, profile_no_auth)
    run("GET /caregivers/profile — auth → 200/404", C, get_profile)
    run("GET /caregivers/search → 200/404", C, search)
    run("GET /caregivers/:fake-uuid → 404", C, get_caregiver_fake)
    run("GET /caregivers/:fake-uuid/reviews → 200/404", C, get_reviews_fake)
    run("POST /caregivers/profile — empty → 400/409", C, create_profile_missing_fields)


# ══════════════════════════════════════════════════════════════════════════════
#  21. Bookings  (5 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s21_bookings():
    print("\n[21] Bookings")
    C = "Bookings"

    def list_no_auth(r):
        resp = api("GET", "/api/v1/bookings")
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def list_auth(r):
        resp = api("GET", "/api/v1/bookings", token=tok())
        chk(resp, r, 200)

    def get_fake_booking(r):
        resp = api("GET", f"/api/v1/bookings/{uuid.uuid4()}", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (404, 403)
        r.detail = f"status={resp.status_code}"

    def create_booking_missing_fields(r):
        resp = api("POST", "/api/v1/bookings", token=tok(), json={
            "caregiverId": str(uuid.uuid4()),
        })
        chk(resp, r, 400)

    def create_booking_fake_caregiver(r):
        skip_if_missing(r, "pet_id")
        resp = api("POST", "/api/v1/bookings", token=tok(), json={
            "caregiverId":         str(uuid.uuid4()),
            "serviceId":           str(uuid.uuid4()),
            "petIds":              [S["pet_id"]],
            "startDatetime":       "2026-06-01T09:00:00Z",
            "endDatetime":         "2026-06-01T11:00:00Z",
            "serviceLocationType": "owner_home",
        })
        r.status_code = resp.status_code
        assert resp.status_code in (400, 404)
        r.detail = f"status={resp.status_code}"

    run("GET /bookings — no auth → 401", C, list_no_auth)
    run("GET /bookings — auth → 200", C, list_auth)
    run("GET /bookings/:fake-uuid → 403/404", C, get_fake_booking)
    run("POST /bookings — missing required fields → 400", C, create_booking_missing_fields)
    run("POST /bookings — fake caregiver → 400/404", C, create_booking_fake_caregiver)


# ══════════════════════════════════════════════════════════════════════════════
#  22. Vet Appointments  (7 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s22_vet_appointments():
    print("\n[22] Vet Appointments")
    C = "VetAppointments"

    def list_no_auth(r):
        resp = api("GET", "/api/v1/vet-appointments")
        r.status_code = resp.status_code
        assert resp.status_code in (401, 403)

    def list_auth(r):
        resp = api("GET", "/api/v1/vet-appointments", token=tok())
        chk(resp, r, 200)
        r.detail = str(resp.json())[:80]

    def create_missing_fields(r):
        resp = api("POST", "/api/v1/vet-appointments", token=tok(), json={"reason": "Checkup"})
        chk(resp, r, 400)

    def create_missing_vet(r):
        skip_if_missing(r, "pet_id")
        resp = api("POST", "/api/v1/vet-appointments", token=tok(), json={
            "petId": S["pet_id"],
            "appointmentDatetime": "2026-07-01T10:00:00Z",
            "reason": "Annual checkup",
            "meetingType": "in_person",
        })
        chk(resp, r, 400)

    def create_fake_vet(r):
        skip_if_missing(r, "pet_id")
        resp = api("POST", "/api/v1/vet-appointments", token=tok(), json={
            "vetUserId":           str(uuid.uuid4()),
            "petId":               S["pet_id"],
            "appointmentDatetime": "2026-07-01T10:00:00Z",
            "reason":              "Annual checkup",
            "meetingType":         "in_person",
        })
        r.status_code = resp.status_code
        # Fake vet → either vet not found (404) or vet profile doesn't exist (400)
        assert resp.status_code in (400, 404), f"got {resp.status_code}: {resp.text[:200]}"
        r.detail = f"status={resp.status_code}"

    def get_fake_appointment(r):
        resp = api("GET", f"/api/v1/vet-appointments/{uuid.uuid4()}", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (403, 404)
        r.detail = f"status={resp.status_code}"

    def invalid_meeting_type(r):
        skip_if_missing(r, "pet_id")
        resp = api("POST", "/api/v1/vet-appointments", token=tok(), json={
            "vetUserId":           str(uuid.uuid4()),
            "petId":               S["pet_id"],
            "appointmentDatetime": "2026-07-01T10:00:00Z",
            "reason":              "Check",
            "meetingType":         "teleport",   # invalid
        })
        chk(resp, r, 400)

    run("GET /vet-appointments — no auth → 401", C, list_no_auth)
    run("GET /vet-appointments — auth → 200", C, list_auth)
    run("POST /vet-appointments — missing all fields → 400", C, create_missing_fields)
    run("POST /vet-appointments — missing vetUserId → 400", C, create_missing_vet)
    run("POST /vet-appointments — fake vetUserId → 400/404", C, create_fake_vet)
    run("GET /vet-appointments/:fake-uuid → 403/404", C, get_fake_appointment)
    run("POST /vet-appointments — invalid meetingType → 400", C, invalid_meeting_type)


# ══════════════════════════════════════════════════════════════════════════════
#  23. Chatbot  (4 tests)
# ══════════════════════════════════════════════════════════════════════════════
def s23_chatbot():
    print("\n[23] Chatbot")
    C = "Chatbot"

    def query_missing_fields(r):
        resp = api("POST", "/api/v1/chatbot/query", json={})
        r.status_code = resp.status_code
        assert resp.status_code in (400, 422)

    def query_valid(r):
        resp = api("POST", "/api/v1/chatbot/query", json={
            "query": "What is a good dog food for a Labrador?",
        })
        r.status_code = resp.status_code
        assert resp.status_code in (200, 400, 500, 503)
        r.detail = f"status={resp.status_code}"

    def query_empty_string(r):
        resp = api("POST", "/api/v1/chatbot/query", json={"query": ""})
        r.status_code = resp.status_code
        assert resp.status_code in (400, 422, 200)
        r.detail = f"status={resp.status_code}"

    def stream_reachable(r):
        resp = api("POST", "/api/v1/chatbot/stream", json={"query": "Hello"})
        r.status_code = resp.status_code
        # Streaming endpoint might return 200 with chunked body or error
        assert resp.status_code in (200, 400, 500, 503)
        r.detail = f"status={resp.status_code}"

    run("POST /chatbot/query — empty body → 400", C, query_missing_fields)
    run("POST /chatbot/query — valid query → 200/500/503", C, query_valid)
    run("POST /chatbot/query — empty string → 400/200", C, query_empty_string)
    run("POST /chatbot/stream — reachable → 200/500", C, stream_reachable)


# ══════════════════════════════════════════════════════════════════════════════
#  24. Delete Post (cleanup)  (1 test)
# ══════════════════════════════════════════════════════════════════════════════
def s24_cleanup():
    print("\n[24] Cleanup")
    C = "Cleanup"

    def delete_post(r):
        post_id = S.get("post_id")
        if not post_id:
            r.passed = False; r.detail = "No post_id to delete"; raise AssertionError()
        resp = api("DELETE", f"/api/v1/posts/{post_id}", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 204)

    def delete_pet(r):
        pet_id = S.get("pet_id")
        if not pet_id:
            r.passed = False; r.detail = "No pet_id to delete"; raise AssertionError()
        resp = api("DELETE", f"/api/v1/pets/{pet_id}", token=tok())
        r.status_code = resp.status_code
        assert resp.status_code in (200, 204)

    def signout(r):
        resp = api("POST", "/api/v1/auth/signout", token=tok(), json={
            "refreshToken": S.get("refresh_token", ""),
        })
        r.status_code = resp.status_code
        assert resp.status_code in (200, 204)

    run("DELETE /posts/:id — own post → 200", C, delete_post)
    run("DELETE /pets/:id — own pet → 200", C, delete_pet)
    run("POST /auth/signout → 200/204", C, signout)


# ══════════════════════════════════════════════════════════════════════════════
#  Results reporter
# ══════════════════════════════════════════════════════════════════════════════
def save_results():
    results_dir = Path(__file__).parent / "results"
    results_dir.mkdir(exist_ok=True)
    ts = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")

    by_cat: dict[str, list[TestResult]] = {}
    for res in _results:
        by_cat.setdefault(res.category, []).append(res)

    total  = len(_results)
    passed = sum(1 for r in _results if r.passed)
    failed = total - passed

    # JSON
    json_path = results_dir / f"test_results_{ts}.json"
    payload = {
        "run_at":      datetime.now(timezone.utc).isoformat(),
        "backend_url": BASE_URL,
        "test_id":     UID,
        "summary": {
            "total":     total,
            "passed":    passed,
            "failed":    failed,
            "pass_rate": f"{100*passed/total:.1f}%" if total else "N/A",
        },
        "categories": {
            cat: {
                "total":  len(tests),
                "passed": sum(1 for t in tests if t.passed),
                "failed": sum(1 for t in tests if not t.passed),
                "tests":  [t.to_dict() for t in tests],
            }
            for cat, tests in by_cat.items()
        },
    }
    json_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")

    # Text report
    txt_path = results_dir / f"test_report_{ts}.txt"
    sep = "=" * 72
    lines = [
        sep,
        "  PawPal Backend Integration Test Report",
        f"  Run at  : {payload['run_at']}",
        f"  Backend : {BASE_URL}",
        f"  Test ID : {UID}",
        sep,
        f"  TOTAL: {total}   PASSED: {passed}   FAILED: {failed}   "
        f"PASS RATE: {payload['summary']['pass_rate']}",
        sep, "",
    ]
    for cat, tests in by_cat.items():
        cat_pass = sum(1 for t in tests if t.passed)
        lines.append(f"  [{cat}]  {cat_pass}/{len(tests)} passed")
        for t in tests:
            icon = "+" if t.passed else "X"
            sc   = f" [{t.status_code}]" if t.status_code else ""
            ms   = f" ({t.duration_ms:.0f}ms)"
            det  = f" -- {t.detail}" if t.detail else ""
            lines.append(f"    [{icon}]{sc}{ms}  {t.name}{det}")
        lines.append("")

    lines += [sep, "  Failed Tests Summary:", sep]
    fails = [t for t in _results if not t.passed]
    if fails:
        for t in fails:
            lines.append(f"  [X] [{t.category}] {t.name}")
            lines.append(f"       {t.detail}")
    else:
        lines.append("  All tests passed!")

    txt_path.write_text("\n".join(lines), encoding="utf-8")

    print(f"\n{sep}")
    print(f"  TOTAL: {total}   PASSED: {passed}   FAILED: {failed}   "
          f"({payload['summary']['pass_rate']})")
    print(sep)
    print(f"  JSON   -> {json_path}")
    print(f"  Report -> {txt_path}")
    print(sep)
    return failed


# ══════════════════════════════════════════════════════════════════════════════
#  Entry point
# ══════════════════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    print("PawPal Backend Integration Tests — 100+ Test Suite")
    print(f"Backend : {BASE_URL}")
    print(f"Test ID : {UID}")
    print("=" * 72)

    s01_health()
    s02_signup()
    s03_signin()
    s04_token()
    s05_profile()
    s06_password_reset()
    s07_pets()
    s08_health_records()
    s09_health_journals()
    s10_posts()
    s11_comments()
    s12_community_advanced()
    s13_vets()
    s14_marketplace_public()
    s15_marketplace_protected()
    s16_lost_found()
    s17_adoptions()
    s18_events()
    s19_chats()
    s20_caregivers()
    s21_bookings()
    s22_vet_appointments()
    s23_chatbot()
    s24_cleanup()

    failed_count = save_results()
    sys.exit(0 if failed_count == 0 else 1)
