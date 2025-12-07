import requests
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv('../.env')

SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_SERVICE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY')

# Delete test users
url = f"{SUPABASE_URL}/rest/v1/users?email=like.test_*@pawpal.com"
headers = {
    'apikey': SUPABASE_SERVICE_KEY,
    'Authorization': f'Bearer {SUPABASE_SERVICE_KEY}',
    'Prefer': 'return=representation'
}

response = requests.delete(url, headers=headers)
print(f"Cleanup Status: {response.status_code}")
if response.status_code == 200:
    print(f"Deleted test users: {response.text}")
else:
    print(f"Response: {response.text}")

# Also cleanup refresh tokens for test users
url_tokens = f"{SUPABASE_URL}/rest/v1/refresh_tokens?user_id=not.is.null"
response_tokens = requests.delete(url_tokens, headers=headers)
print(f"Cleanup refresh tokens: {response_tokens.status_code}")
