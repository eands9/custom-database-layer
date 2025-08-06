#!/usr/bin/env python3
"""
Python script to insert new cat data into the PostgreSQL database.
"""

import psycopg2
from psycopg2 import sql
import sys
import os
from typing import List, Tuple, Optional, Dict, Any
from datetime import date, datetime
import random

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

def insert_single_cat(cursor: psycopg2.extensions.cursor, cat_data: Dict[str, Any]) -> bool:
    """
    Insert a single cat record into the database.
    
    Args:
        cursor: Database cursor object
        cat_data: Dictionary containing cat information
        
    Returns:
        True if insertion successful, False otherwise
    """
    try:
        insert_query = """
            INSERT INTO cats (name, breed, age, color, weight_kg, is_indoor, adoption_date, description)
            VALUES (%(name)s, %(breed)s, %(age)s, %(color)s, %(weight_kg)s, %(is_indoor)s, %(adoption_date)s, %(description)s)
            RETURNING id;
        """
        
        cursor.execute(insert_query, cat_data)
        cat_id = cursor.fetchone()[0]
        print(f"✅ Successfully inserted cat '{cat_data['name']}' with ID: {cat_id}")
        return True
        
    except psycopg2.Error as e:
        print(f"❌ Error inserting cat '{cat_data.get('name', 'Unknown')}': {e}")
        return False

def insert_multiple_cats(cursor: psycopg2.extensions.cursor, cats_data: List[Dict[str, Any]]) -> int:
    """
    Insert multiple cat records into the database.
    
    Args:
        cursor: Database cursor object
        cats_data: List of dictionaries containing cat information
        
    Returns:
        Number of successfully inserted records
    """
    success_count = 0
    
    for cat_data in cats_data:
        if insert_single_cat(cursor, cat_data):
            success_count += 1
    
    return success_count

def get_user_input_for_cat() -> Dict[str, Any]:
    """
    Get cat information from user input.
    
    Returns:
        Dictionary containing cat data
    """
    print("\n📝 Enter cat information:")
    print("-" * 30)
    
    cat_data = {}
    
    # Required fields
    cat_data['name'] = input("Cat name: ").strip()
    if not cat_data['name']:
        raise ValueError("Cat name is required!")
    
    cat_data['breed'] = input("Breed: ").strip() or None
    
    # Age validation
    while True:
        try:
            age_input = input("Age (years): ").strip()
            cat_data['age'] = int(age_input) if age_input else None
            if cat_data['age'] is not None and (cat_data['age'] < 0 or cat_data['age'] > 30):
                print("❌ Age must be between 0 and 30 years")
                continue
            break
        except ValueError:
            print("❌ Please enter a valid number for age")
    
    cat_data['color'] = input("Color: ").strip() or None
    
    # Weight validation
    while True:
        try:
            weight_input = input("Weight (kg): ").strip()
            if weight_input:
                cat_data['weight_kg'] = float(weight_input)
                if cat_data['weight_kg'] < 0 or cat_data['weight_kg'] > 20:
                    print("❌ Weight must be between 0 and 20 kg")
                    continue
            else:
                cat_data['weight_kg'] = None
            break
        except ValueError:
            print("❌ Please enter a valid number for weight")
    
    # Indoor/Outdoor
    while True:
        indoor_input = input("Is indoor cat? (y/n): ").strip().lower()
        if indoor_input in ['y', 'yes', '1', 'true']:
            cat_data['is_indoor'] = True
            break
        elif indoor_input in ['n', 'no', '0', 'false']:
            cat_data['is_indoor'] = False
            break
        elif indoor_input == '':
            cat_data['is_indoor'] = True  # Default to indoor
            break
        else:
            print("❌ Please enter 'y' for yes or 'n' for no")
    
    # Adoption date
    while True:
        date_input = input("Adoption date (YYYY-MM-DD) or press Enter for today: ").strip()
        if not date_input:
            cat_data['adoption_date'] = date.today()
            break
        try:
            cat_data['adoption_date'] = datetime.strptime(date_input, '%Y-%m-%d').date()
            break
        except ValueError:
            print("❌ Please enter date in YYYY-MM-DD format")
    
    cat_data['description'] = input("Description: ").strip() or None
    
    return cat_data

def generate_random_cats(count: int) -> List[Dict[str, Any]]:
    """
    Generate random cat data for testing purposes.
    
    Args:
        count: Number of random cats to generate
        
    Returns:
        List of cat data dictionaries
    """
    cat_names = [
        "Fluffy", "Oreo", "Felix", "Bella", "Max", "Lucy", "Charlie", "Molly",
        "Oscar", "Ruby", "Leo", "Daisy", "Milo", "Sophie", "Simba", "Chloe",
        "Jasper", "Lily", "Oliver", "Zoe", "Chester", "Maya", "Toby", "Emma"
    ]
    
    cat_breeds = [
        "Persian", "Siamese", "Maine Coon", "British Shorthair", "Ragdoll",
        "Bengal", "Russian Blue", "Scottish Fold", "Abyssinian", "Birman",
        "Norwegian Forest Cat", "Oriental", "Burmese", "Egyptian Mau", "Manx"
    ]
    
    cat_colors = [
        "Black", "White", "Gray", "Orange", "Brown", "Cream", "Silver",
        "Calico", "Tabby", "Tortoiseshell", "Tuxedo", "Blue", "Red"
    ]
    
    descriptions = [
        "A playful and energetic cat who loves to chase toys",
        "Calm and gentle, perfect for families with children",
        "Very affectionate and enjoys being petted",
        "Independent but loyal, great for apartment living",
        "Curious and intelligent, loves to explore",
        "Shy at first but becomes very loving once comfortable",
        "Active outdoor cat who enjoys climbing trees",
        "Lazy indoor cat who loves to sleep in sunny spots",
        "Social cat who gets along well with other pets",
        "Vocal cat who likes to 'talk' to their owners"
    ]
    
    cats_data = []
    
    for i in range(count):
        cat_data = {
            'name': random.choice(cat_names),
            'breed': random.choice(cat_breeds),
            'age': random.randint(1, 15),
            'color': random.choice(cat_colors),
            'weight_kg': round(random.uniform(2.5, 8.0), 2),
            'is_indoor': random.choice([True, False]),
            'adoption_date': date.today(),
            'description': random.choice(descriptions)
        }
        cats_data.append(cat_data)
    
    return cats_data

def display_cat_info(cat_data: Dict[str, Any]) -> None:
    """
    Display cat information in a formatted way.
    
    Args:
        cat_data: Dictionary containing cat information
    """
    print(f"\n🐱 Cat Information:")
    print("-" * 40)
    print(f"Name: {cat_data['name']}")
    print(f"Breed: {cat_data['breed'] or 'Unknown'}")
    print(f"Age: {cat_data['age'] or 'Unknown'} years")
    print(f"Color: {cat_data['color'] or 'Unknown'}")
    print(f"Weight: {cat_data['weight_kg'] or 'Unknown'} kg")
    print(f"Status: {'Indoor' if cat_data['is_indoor'] else 'Outdoor'}")
    print(f"Adoption Date: {cat_data['adoption_date']}")
    print(f"Description: {cat_data['description'] or 'No description'}")

def main():
    """
    Main function to execute the data insertion operations.
    """
    print("🐱 PostgreSQL Cats Database - Data Insertion Tool")
    print("=" * 60)
    
    # Connect to database
    connection = connect_to_database()
    if not connection:
        sys.exit(1)
    
    try:
        cursor = connection.cursor()
        
        while True:
            print("\n📋 Choose an option:")
            print("1. Insert a single cat manually")
            print("2. Insert multiple cats manually")
            print("3. Generate and insert random cats")
            print("4. Exit")
            
            choice = input("\nEnter your choice (1-4): ").strip()
            
            if choice == '1':
                try:
                    cat_data = get_user_input_for_cat()
                    display_cat_info(cat_data)
                    
                    confirm = input("\n❓ Do you want to insert this cat? (y/n): ").strip().lower()
                    if confirm in ['y', 'yes']:
                        if insert_single_cat(cursor, cat_data):
                            connection.commit()
                            print("✅ Cat data committed to database!")
                        else:
                            connection.rollback()
                            print("❌ Failed to insert cat data. Transaction rolled back.")
                    else:
                        print("❌ Cat insertion cancelled.")
                        
                except ValueError as e:
                    print(f"❌ Error: {e}")
                except KeyboardInterrupt:
                    print("\n❌ Operation cancelled by user.")
            
            elif choice == '2':
                try:
                    count = int(input("How many cats do you want to add? "))
                    if count <= 0:
                        print("❌ Number must be greater than 0")
                        continue
                    
                    cats_data = []
                    for i in range(count):
                        print(f"\n--- Cat {i + 1} of {count} ---")
                        cat_data = get_user_input_for_cat()
                        cats_data.append(cat_data)
                    
                    print(f"\n📋 Summary: {len(cats_data)} cats ready to insert")
                    confirm = input("❓ Do you want to insert all cats? (y/n): ").strip().lower()
                    
                    if confirm in ['y', 'yes']:
                        success_count = insert_multiple_cats(cursor, cats_data)
                        if success_count > 0:
                            connection.commit()
                            print(f"✅ Successfully inserted {success_count}/{len(cats_data)} cats!")
                        else:
                            connection.rollback()
                            print("❌ No cats were inserted. Transaction rolled back.")
                    else:
                        print("❌ Bulk insertion cancelled.")
                        
                except ValueError:
                    print("❌ Please enter a valid number")
                except KeyboardInterrupt:
                    print("\n❌ Operation cancelled by user.")
            
            elif choice == '3':
                try:
                    count = int(input("How many random cats do you want to generate? "))
                    if count <= 0:
                        print("❌ Number must be greater than 0")
                        continue
                    
                    cats_data = generate_random_cats(count)
                    print(f"\n📋 Generated {len(cats_data)} random cats")
                    
                    # Show first few cats as preview
                    print("\n🔍 Preview (first 3 cats):")
                    for i, cat_data in enumerate(cats_data[:3]):
                        print(f"\nCat {i + 1}:")
                        display_cat_info(cat_data)
                    
                    if len(cats_data) > 3:
                        print(f"\n... and {len(cats_data) - 3} more cats")
                    
                    confirm = input(f"\n❓ Do you want to insert all {len(cats_data)} random cats? (y/n): ").strip().lower()
                    
                    if confirm in ['y', 'yes']:
                        success_count = insert_multiple_cats(cursor, cats_data)
                        if success_count > 0:
                            connection.commit()
                            print(f"✅ Successfully inserted {success_count}/{len(cats_data)} random cats!")
                        else:
                            connection.rollback()
                            print("❌ No cats were inserted. Transaction rolled back.")
                    else:
                        print("❌ Random cat insertion cancelled.")
                        
                except ValueError:
                    print("❌ Please enter a valid number")
            
            elif choice == '4':
                print("👋 Goodbye!")
                break
            
            else:
                print("❌ Invalid choice. Please enter 1, 2, 3, or 4.")
        
        cursor.close()
        
    except Exception as e:
        print(f"❌ An unexpected error occurred: {e}")
        connection.rollback()
    finally:
        if connection:
            connection.close()
            print("\n✅ Database connection closed.")

if __name__ == "__main__":
    main()
