#!/usr/bin/env python3
"""
Python script to connect to the local PostgreSQL database and display cats data.
"""

import psycopg2
from psycopg2 import sql
import sys
import os
from typing import List, Tuple, Optional

# Load environment variables from .env file if python-dotenv is available
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    print("📝 Note: python-dotenv not installed. Using system environment variables only.")

# Database connection parameters from environment variables
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', '5432')),
    'database': os.getenv('POSTGRES_DB', 'catsdb'),
    'user': os.getenv('POSTGRES_USER', 'postgres'),
    'password': os.getenv('POSTGRES_PASSWORD', 'password')
}

def connect_to_database() -> Optional[psycopg2.extensions.connection]:
    """
    Establish connection to PostgreSQL database.
    
    Returns:
        Database connection object or None if connection fails
    """
    try:
        connection = psycopg2.connect(**DB_CONFIG)
        print("✅ Successfully connected to PostgreSQL database!")
        return connection
    except psycopg2.Error as e:
        print(f"❌ Error connecting to PostgreSQL database: {e}")
        return None

def check_table_exists(cursor: psycopg2.extensions.cursor) -> bool:
    """
    Check if the cats table exists in the database.
    
    Args:
        cursor: Database cursor object
        
    Returns:
        True if table exists, False otherwise
    """
    try:
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name = 'cats'
            );
        """)
        return cursor.fetchone()[0]
    except psycopg2.Error as e:
        print(f"❌ Error checking table existence: {e}")
        return False

def get_table_info(cursor: psycopg2.extensions.cursor) -> None:
    """
    Display information about the cats table structure.
    
    Args:
        cursor: Database cursor object
    """
    try:
        cursor.execute("""
            SELECT column_name, data_type, is_nullable, column_default
            FROM information_schema.columns
            WHERE table_name = 'cats'
            ORDER BY ordinal_position;
        """)
        
        columns = cursor.fetchall()
        print("\n📋 Table Structure:")
        print("-" * 80)
        print(f"{'Column Name':<20} {'Data Type':<20} {'Nullable':<10} {'Default':<20}")
        print("-" * 80)
        
        for column in columns:
            col_name, data_type, nullable, default = column
            default_str = str(default) if default else "None"
            print(f"{col_name:<20} {data_type:<20} {nullable:<10} {default_str:<20}")
            
    except psycopg2.Error as e:
        print(f"❌ Error getting table info: {e}")

def get_cats_count(cursor: psycopg2.extensions.cursor) -> int:
    """
    Get the total number of cats in the database.
    
    Args:
        cursor: Database cursor object
        
    Returns:
        Number of cats in the database
    """
    try:
        cursor.execute("SELECT COUNT(*) FROM cats;")
        count = cursor.fetchone()[0]
        print(f"\n📊 Total number of cats in database: {count}")
        return count
    except psycopg2.Error as e:
        print(f"❌ Error getting cats count: {e}")
        return 0

def display_all_cats(cursor: psycopg2.extensions.cursor) -> None:
    """
    Display all cats data in a formatted table.
    
    Args:
        cursor: Database cursor object
    """
    try:
        cursor.execute("""
            SELECT id, name, breed, age, color, weight_kg, is_indoor, 
                   adoption_date, description
            FROM cats 
            ORDER BY id;
        """)
        
        cats = cursor.fetchall()
        
        if not cats:
            print("\n❌ No cats found in the database.")
            return
            
        print("\n🐱 All Cats Data:")
        print("=" * 120)
        
        for cat in cats:
            cat_id, name, breed, age, color, weight, is_indoor, adoption_date, description = cat
            indoor_status = "Indoor" if is_indoor else "Outdoor"
            
            print(f"ID: {cat_id}")
            print(f"Name: {name}")
            print(f"Breed: {breed}")
            print(f"Age: {age} years")
            print(f"Color: {color}")
            print(f"Weight: {weight} kg")
            print(f"Status: {indoor_status}")
            print(f"Adoption Date: {adoption_date}")
            print(f"Description: {description}")
            print("-" * 120)
            
    except psycopg2.Error as e:
        print(f"❌ Error displaying cats data: {e}")

def display_cats_summary(cursor: psycopg2.extensions.cursor) -> None:
    """
    Display summary statistics about the cats.
    
    Args:
        cursor: Database cursor object
    """
    try:
        # Breed statistics
        cursor.execute("""
            SELECT breed, COUNT(*) as count
            FROM cats 
            GROUP BY breed 
            ORDER BY count DESC;
        """)
        breeds = cursor.fetchall()
        
        print("\n📈 Cats by Breed:")
        print("-" * 40)
        for breed, count in breeds:
            print(f"{breed:<25} {count:>3}")
        
        # Age statistics
        cursor.execute("""
            SELECT 
                AVG(age) as avg_age,
                MIN(age) as min_age,
                MAX(age) as max_age
            FROM cats;
        """)
        age_stats = cursor.fetchone()
        
        print(f"\n📊 Age Statistics:")
        print("-" * 30)
        print(f"Average Age: {age_stats[0]:.1f} years")
        print(f"Youngest Cat: {age_stats[1]} years")
        print(f"Oldest Cat: {age_stats[2]} years")
        
        # Indoor vs Outdoor
        cursor.execute("""
            SELECT is_indoor, COUNT(*) as count
            FROM cats 
            GROUP BY is_indoor;
        """)
        indoor_stats = cursor.fetchall()
        
        print(f"\n🏠 Indoor vs Outdoor:")
        print("-" * 25)
        for is_indoor, count in indoor_stats:
            status = "Indoor" if is_indoor else "Outdoor"
            print(f"{status}: {count}")
            
    except psycopg2.Error as e:
        print(f"❌ Error getting summary statistics: {e}")

def search_cats_by_breed(cursor: psycopg2.extensions.cursor, breed: str) -> None:
    """
    Search and display cats by breed.
    
    Args:
        cursor: Database cursor object
        breed: Breed name to search for
    """
    try:
        cursor.execute("""
            SELECT name, age, color, is_indoor
            FROM cats 
            WHERE LOWER(breed) LIKE LOWER(%s)
            ORDER BY name;
        """, (f"%{breed}%",))
        
        cats = cursor.fetchall()
        
        if not cats:
            print(f"\n❌ No cats found with breed containing '{breed}'")
            return
            
        print(f"\n🔍 Cats with breed containing '{breed}':")
        print("-" * 60)
        print(f"{'Name':<15} {'Age':<5} {'Color':<15} {'Status':<10}")
        print("-" * 60)
        
        for cat in cats:
            name, age, color, is_indoor = cat
            status = "Indoor" if is_indoor else "Outdoor"
            print(f"{name:<15} {age:<5} {color:<15} {status:<10}")
            
    except psycopg2.Error as e:
        print(f"❌ Error searching cats by breed: {e}")

def main():
    """
    Main function to execute the database operations.
    """
    print("🐱 PostgreSQL Cats Database Checker")
    print("=" * 50)
    
    # Connect to database
    connection = connect_to_database()
    if not connection:
        sys.exit(1)
    
    try:
        cursor = connection.cursor()
        
        # Check if table exists
        if not check_table_exists(cursor):
            print("❌ Cats table does not exist in the database!")
            sys.exit(1)
        
        print("✅ Cats table found!")
        
        # Display table information
        get_table_info(cursor)
        
        # Get and display count
        count = get_cats_count(cursor)
        
        if count > 0:
            # Display all cats
            display_all_cats(cursor)
            
            # Display summary statistics
            display_cats_summary(cursor)
            
            # Example search
            print("\n" + "=" * 50)
            search_cats_by_breed(cursor, "Maine")
            
        cursor.close()
        
    except Exception as e:
        print(f"❌ An error occurred: {e}")
    finally:
        if connection:
            connection.close()
            print("\n✅ Database connection closed.")

if __name__ == "__main__":
    main()
