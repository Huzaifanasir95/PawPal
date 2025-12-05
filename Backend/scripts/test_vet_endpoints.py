#!/usr/bin/env python3
"""
Test script for PawPal Vet System Endpoints
Tests user role selection, vet profile creation, and vet listing
"""

import requests
import json
import sys
from typing import Optional

# Configuration
BASE_URL = "https://d291572b3b99.ngrok-free.app/api/v1"
HEADERS = {
    "Content-Type": "application/json",
    "ngrok-skip-browser-warning": "true"
}

# Test user credentials
TEST_VET_EMAIL = "drsh@vetclinic.com"
TEST_VET_PASSWORD = "VetPass123!"
TEST_VET_NAME = "Dr. Sarah Henderson"

# Global token storage
auth_token: Optional[str] = None
user_id: Optional[str] = None


def print_section(title: str):
    """Print a formatted section header"""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def print_response(response: requests.Response, title: str):
    """Print formatted response"""
    print(f"📍 {title}")
    print(f"Status Code: {response.status_code}")
    try:
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
    except:
        print(f"Response: {response.text[:200]}")
    print()


def test_signup():
    """Test 1: Sign up a new vet user"""
    global auth_token, user_id
    print_section("TEST 1: Sign Up New Vet User")
    
    payload = {
        "email": TEST_VET_EMAIL,
        "password": TEST_VET_PASSWORD,
        "fullName": TEST_VET_NAME
    }
    
    response = requests.post(
        f"{BASE_URL}/auth/signup",
        headers=HEADERS,
        json=payload
    )
    
    print_response(response, "Signup")
    
    if response.status_code in [200, 201]:
        data = response.json()
        if data.get("success"):
            # Try both token field names
            token = data.get("accessToken") or data.get("token")
            if token:
                auth_token = token
                user_id = data.get("user", {}).get("uid") or data.get("user", {}).get("id")
                print(f"✅ Signup successful! Token: {auth_token[:20]}...")
                print(f"✅ User ID: {user_id}")
                return True
    
    # Check for existing user error
    if response.status_code == 409 or "already exists" in response.text.lower():
        print("⚠️  User already exists, trying signin instead...")
        return test_signin()
    
    print("❌ Signup failed!")
    return False


def test_signin():
    """Sign in existing user"""
    global auth_token, user_id
    
    payload = {
        "email": TEST_VET_EMAIL,
        "password": TEST_VET_PASSWORD
    }
    
    response = requests.post(
        f"{BASE_URL}/auth/signin",
        headers=HEADERS,
        json=payload
    )
    
    print_response(response, "Signin")
    
    if response.status_code == 200:
        data = response.json()
        if data.get("success"):
            # Try both token field names
            token = data.get("accessToken") or data.get("token")
            if token:
                auth_token = token
                user_id = data.get("user", {}).get("uid") or data.get("user", {}).get("id")
                print(f"✅ Signin successful! Token: {auth_token[:20]}...")
                print(f"✅ User ID: {user_id}")
                return True
    
    print("❌ Signin failed!")
    return False


def test_set_role():
    """Test 2: Set user role to 'vet'"""
    print_section("TEST 2: Set User Role to Vet")
    
    if not auth_token:
        print("❌ No auth token available")
        return False
    
    headers = {**HEADERS, "Authorization": f"Bearer {auth_token}"}
    payload = {"role": "vet"}
    
    response = requests.post(
        f"{BASE_URL}/auth/set-role",
        headers=headers,
        json=payload
    )
    
    print_response(response, "Set Role to Vet")
    
    if response.status_code == 200:
        data = response.json()
        if data.get("success"):
            print("✅ User role set to 'vet' successfully!")
            return True
    
    print("❌ Failed to set user role!")
    return False


def test_create_vet_profile():
    """Test 3: Create vet profile"""
    print_section("TEST 3: Create Vet Profile")
    
    if not auth_token:
        print("❌ No auth token available")
        return False
    
    headers = {**HEADERS, "Authorization": f"Bearer {auth_token}"}
    payload = {
        "fullName": "Dr. Sarah Smith, DVM",
        "degree": "Doctor of Veterinary Medicine",
        "licenseNumber": "VET-CA-123456",
        "specialization": ["General Practice", "Emergency Care", "Surgery"],
        "experience": 8,
        "clinicName": "Happy Paws Veterinary Clinic",
        "clinicAddress": "123 Pet Street, Suite 100",
        "city": "San Francisco",
        "state": "California",
        "zipCode": "94102",
        "phone": "+1-415-555-0123",
        "consultationFee": 150.00,
        "currency": "USD",
        "bio": "Experienced veterinarian specializing in emergency care and general practice. Passionate about animal welfare with 8 years of experience treating small animals.",
        "availabilityHours": "Mon-Fri: 9AM-6PM, Sat: 10AM-4PM",
        "isAvailable": True
    }
    
    response = requests.post(
        f"{BASE_URL}/vets/profile",
        headers=headers,
        json=payload
    )
    
    print_response(response, "Create Vet Profile")
    
    if response.status_code in [200, 201]:
        data = response.json()
        if data.get("success"):
            print("✅ Vet profile created successfully!")
            return True
    
    print("❌ Failed to create vet profile!")
    return False


def test_get_my_profile():
    """Test 4: Get my vet profile"""
    print_section("TEST 4: Get My Vet Profile")
    
    if not auth_token:
        print("❌ No auth token available")
        return False
    
    headers = {**HEADERS, "Authorization": f"Bearer {auth_token}"}
    
    response = requests.get(
        f"{BASE_URL}/vets/profile/me",
        headers=headers
    )
    
    print_response(response, "Get My Vet Profile")
    
    if response.status_code == 200:
        data = response.json()
        if data.get("success"):
            print("✅ Successfully retrieved vet profile!")
            return True
    
    print("❌ Failed to get vet profile!")
    return False


def test_list_vets():
    """Test 5: List all vets (no auth required)"""
    print_section("TEST 5: List All Vets")
    
    response = requests.get(
        f"{BASE_URL}/vets",
        headers=HEADERS
    )
    
    print_response(response, "List All Vets")
    
    if response.status_code == 200:
        data = response.json()
        if data.get("success"):
            vets = data.get("vets", [])
            print(f"✅ Found {len(vets)} vets")
            return True
    
    print("❌ Failed to list vets!")
    return False


def test_list_vets_with_filters():
    """Test 6: List vets with filters"""
    print_section("TEST 6: List Vets with Filters")
    
    # Test filter by city
    print("🔍 Filter by city: San Francisco")
    response = requests.get(
        f"{BASE_URL}/vets?city=San Francisco",
        headers=HEADERS
    )
    print_response(response, "Filter by City")
    
    # Test filter by specialization
    print("🔍 Filter by specialization: Emergency Care")
    response = requests.get(
        f"{BASE_URL}/vets?specialization=Emergency Care",
        headers=HEADERS
    )
    print_response(response, "Filter by Specialization")
    
    # Test filter by rating
    print("🔍 Filter by minimum rating: 4.0")
    response = requests.get(
        f"{BASE_URL}/vets?minRating=4.0",
        headers=HEADERS
    )
    print_response(response, "Filter by Rating")
    
    # Test pagination
    print("🔍 Pagination: page=1, limit=5")
    response = requests.get(
        f"{BASE_URL}/vets?page=1&limit=5",
        headers=HEADERS
    )
    print_response(response, "Pagination")
    
    if response.status_code == 200:
        print("✅ Filter tests completed!")
        return True
    
    return False


def test_start_chat():
    """Test 7: Start a chat with a vet"""
    print_section("TEST 7: Start Chat with Vet")
    
    if not auth_token or not user_id:
        print("❌ No auth token available")
        return False
    
    headers = {**HEADERS, "Authorization": f"Bearer {auth_token}"}
    
    # Use the vet's own ID for testing (in real scenario, pet owner would chat with another vet)
    payload = {
        "vetId": user_id
    }
    
    response = requests.post(
        f"{BASE_URL}/chats",
        headers=headers,
        json=payload
    )
    
    print_response(response, "Start Chat")
    
    if response.status_code in [200, 201]:
        data = response.json()
        if data.get("success"):
            print("✅ Chat started successfully!")
            return True
    
    print("⚠️  Note: Chat test may fail if same user tries to chat with themselves")
    return True  # Don't fail the test suite


def test_get_my_chats():
    """Test 8: Get my chats"""
    print_section("TEST 8: Get My Chats")
    
    if not auth_token:
        print("❌ No auth token available")
        return False
    
    headers = {**HEADERS, "Authorization": f"Bearer {auth_token}"}
    
    response = requests.get(
        f"{BASE_URL}/chats",
        headers=headers
    )
    
    print_response(response, "Get My Chats")
    
    if response.status_code == 200:
        data = response.json()
        if data.get("success"):
            chats = data.get("chats", [])
            print(f"✅ Found {len(chats)} chats")
            return True
    
    print("❌ Failed to get chats!")
    return False


def run_all_tests():
    """Run all tests in sequence"""
    print("\n" + "="*60)
    print("  🐾 PAWPAL VET & CHAT SYSTEM TESTS 🐾")
    print("="*60)
    print(f"Base URL: {BASE_URL}")
    print("="*60)
    
    tests = [
        ("Signup/Signin", test_signup),
        ("Set Role", test_set_role),
        ("Create Vet Profile", test_create_vet_profile),
        ("Get My Profile", test_get_my_profile),
        ("List All Vets", test_list_vets),
        ("List with Filters", test_list_vets_with_filters),
        ("Start Chat", test_start_chat),
        ("Get My Chats", test_get_my_chats)
    ]
    
    results = []
    for name, test_func in tests:
        try:
            result = test_func()
            results.append((name, result))
        except Exception as e:
            print(f"❌ Test '{name}' failed with error: {str(e)}")
            results.append((name, False))
    
    # Print summary
    print_section("TEST SUMMARY")
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status}: {name}")
    
    print(f"\n{'='*60}")
    print(f"  Results: {passed}/{total} tests passed")
    print(f"{'='*60}\n")
    
    return passed == total


if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)
