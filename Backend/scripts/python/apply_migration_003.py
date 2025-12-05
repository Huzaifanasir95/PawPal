"""
Apply migration 003 to fix the chat schema
This fixes the last_message_time -> last_message_at rename issue
"""
import os
import psycopg2
from urllib.parse import urlparse

def apply_migration():
    # Use Supabase connection string
    database_url = "postgresql://postgres.vevmesyynclspedlbbql:Pawpal123@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres"
    
    print(f"Connecting to Supabase database...")
    print(f"Host: aws-0-ap-southeast-1.pooler.supabase.com")
    
    # Connect to database
    try:
        conn = psycopg2.connect(database_url)
        conn.autocommit = False
        
        cursor = conn.cursor()
        
        print("Connected to database successfully")
        
        # Read migration file
        migration_path = os.path.join(
            os.path.dirname(__file__), 
            '..', 
            'internal', 
            'database', 
            'migrations', 
            '003_fix_chat_schema.sql'
        )
        
        with open(migration_path, 'r') as f:
            migration_sql = f.read()
        
        print("Applying migration 003: Fix chat schema...")
        print("-" * 60)
        
        # Execute migration
        cursor.execute(migration_sql)
        conn.commit()
        
        print("-" * 60)
        print("✅ Migration 003 applied successfully!")
        print("\nChanges made:")
        print("  - Renamed last_message_time to last_message_at")
        print("  - Added pet_id column to chats table")
        print("  - Split unread_count into unread_count_owner and unread_count_vet")
        print("  - Removed sender_role from messages table")
        print("  - Updated trigger function for new column names")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"❌ Error applying migration: {e}")
        if conn:
            conn.rollback()
            conn.close()

if __name__ == "__main__":
    apply_migration()
