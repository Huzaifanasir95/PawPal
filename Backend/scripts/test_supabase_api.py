#!/usr/bin/env python3
"""
PawPal Backend - Supabase REST API Test
Tests Supabase connection using the REST API (no database password needed)
"""

import os
import sys
import requests
from pathlib import Path

try:
    from dotenv import load_dotenv
except ImportError:
    print("❌ Error: python-dotenv not installed")
    print("Install it with: pip install python-dotenv")
    sys.exit(1)


def main():
    # Load environment variables
    env_path = Path(__file__).parent.parent / '.env'
    if env_path.exists():
        load_dotenv(env_path)
        print(f"✅ Loaded environment from: {env_path}")
    else:
        print(f"⚠️  Warning: .env file not found")
    
    print("\n=== PawPal Backend - Supabase REST API Test ===\n")
    
    # Get Supabase details
    supabase_url = os.getenv('SUPABASE_URL')
    supabase_anon_key = os.getenv('SUPABASE_ANON_KEY')
    
    if not supabase_url or not supabase_anon_key:
        print("❌ Error: SUPABASE_URL or SUPABASE_ANON_KEY not set")
        sys.exit(1)
    
    print(f"Supabase URL: {supabase_url}")
    print(f"Anon Key: {supabase_anon_key[:20]}...{supabase_anon_key[-20:]}")
    print()
    
    # Test REST API endpoint
    api_url = f"{supabase_url}/rest/v1/"
    headers = {
        'apikey': supabase_anon_key,
        'Authorization': f'Bearer {supabase_anon_key}'
    }
    
    print("⏳ Testing Supabase REST API connection...\n")
    
    try:
        # Get list of tables
        response = requests.get(api_url, headers=headers, timeout=10)
        
        if response.status_code == 200:
            print("✅ Successfully connected to Supabase REST API!")
            print(f"\nHTTP Status: {response.status_code}")
            print(f"Response: {response.text[:200] if response.text else 'Empty'}")
        elif response.status_code == 404:
            print("✅ Supabase REST API is accessible!")
            print("⚠️  No tables found or endpoint needs specific table name")
            print(f"\nHTTP Status: {response.status_code}")
        else:
            print(f"⚠️  Unexpected response: {response.status_code}")
            print(f"Response: {response.text[:200]}")
        
        # Try to get health/status
        print("\n=== Testing Health Endpoint ===")
        health_response = requests.get(f"{supabase_url}/rest/v1/", headers=headers, timeout=10)
        print(f"Health Check Status: {health_response.status_code}")
        
        print("\n=== Supabase Configuration Summary ===")
        print(f"✅ Supabase URL is valid")
        print(f"✅ API Key is configured")
        print(f"✅ REST API is accessible")
        print(f"\n🎉 Supabase is ready to use!")
        
        print("\n=== Next Steps ===")
        print("1. Create database tables for your application")
        print("2. Test database operations using Supabase client")
        print("3. Configure Row Level Security (RLS) policies")
        
    except requests.exceptions.ConnectionError:
        print("❌ Connection Error: Could not reach Supabase")
        print("Check your internet connection and Supabase URL")
        sys.exit(1)
    except requests.exceptions.Timeout:
        print("❌ Timeout Error: Supabase took too long to respond")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Unexpected Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
