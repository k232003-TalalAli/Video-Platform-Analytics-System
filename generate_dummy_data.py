import random
import sqlite3
import uuid
from datetime import datetime, timedelta


def clear_databases():
    """Clear all existing data from both databases."""
    # Clear analytics database
    conn = sqlite3.connect('lib/DB/youtube_analytics.db')
    cursor = conn.cursor()
    
    # Get all tables
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()
    
    # Drop all tables except sqlite_sequence
    for table in tables:
        if table[0] != 'sqlite_sequence':
            cursor.execute(f"DROP TABLE IF EXISTS {table[0]};")
    
    conn.commit()
    conn.close()

    # Clear login database
    conn = sqlite3.connect('lib/login/login_users.db')
    cursor = conn.cursor()
    
    # Drop login_users table
    cursor.execute("DROP TABLE IF EXISTS login_users;")
    
    conn.commit()
    conn.close()


def create_tables():
    """Create the necessary tables in both databases."""
    # Create analytics tables
    conn = sqlite3.connect('lib/DB/youtube_analytics.db')
    cursor = conn.cursor()
    
    # Create all_users table
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS all_users (
        user_id TEXT PRIMARY KEY,
        user_name TEXT NOT NULL,
        channel_creation_date TEXT NOT NULL,
        channel_name TEXT NOT NULL,
        total_views INTEGER NOT NULL,
        total_subs INTEGER NOT NULL,
        total_comments INTEGER NOT NULL,
        total_watchtime INTEGER NOT NULL,
        total_revenue REAL NOT NULL,
        channel_image_link TEXT NOT NULL,
        description TEXT NOT NULL
    )
    ''')
    
    conn.commit()
    conn.close()

    # Create login table
    conn = sqlite3.connect('lib/login/login_users.db')
    cursor = conn.cursor()
    
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS login_users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
    )
    ''')
    
    conn.commit()
    conn.close()


def generate_user_data():
    """Generate data for 5 users."""
    users = []
    for i in range(5):
        user_id = str(uuid.uuid4())
        creation_date = datetime.now().isoformat()
        
        user = {
            'user_id': user_id,
            'user_name': f'User{i+1}',
            'channel_creation_date': creation_date,
            'channel_name': f'Channel{i+1}',
            'total_views': 0,  # Will be updated after adding videos
            'total_subs': random.randint(1000, 100000),
            'total_comments': 0,  # Will be updated after adding videos
            'total_watchtime': 0,  # Will be updated after adding videos
            'total_revenue': 0.0,  # Will be updated after adding videos
            'channel_image_link': f'https://example.com/channel{i+1}.jpg',
            'description': f'This is the description for Channel{i+1}'
        }
        users.append(user)
    return users

def create_user_video_table(user_id):
    """Create a table for user's videos."""
    conn = sqlite3.connect('lib/DB/youtube_analytics.db')
    cursor = conn.cursor()
    
    safe_user_id = user_id.replace('-', '_')
    cursor.execute(f'''
    CREATE TABLE IF NOT EXISTS user_{safe_user_id} (
        video_id TEXT PRIMARY KEY,
        video_name TEXT NOT NULL,
        views INTEGER NOT NULL,
        subs INTEGER NOT NULL,
        revenue REAL NOT NULL,
        comments INTEGER NOT NULL,
        watchtime INTEGER NOT NULL,
        creation_date TEXT NOT NULL
    )
    ''')
    
    conn.commit()
    conn.close()

def create_video_metrics_table(video_id):
    """Create a table for video metrics."""
    conn = sqlite3.connect('lib/DB/youtube_analytics.db')
    cursor = conn.cursor()
    
    safe_video_id = video_id.replace('-', '_')
    cursor.execute(f'''
    CREATE TABLE IF NOT EXISTS video_metrics_{safe_video_id} (
        metric_id TEXT PRIMARY KEY,
        day TEXT NOT NULL,
        day_views INTEGER NOT NULL,
        impressions INTEGER NOT NULL,
        ctr REAL NOT NULL,
        watchtime INTEGER NOT NULL
    )
    ''')
    
    conn.commit()
    conn.close()

def generate_video_metrics(total_views, total_watchtime, creation_date):
    """Generate 30 days of metrics for a video that sum up to the total values."""
    metrics = []
    start_date = datetime.fromisoformat(creation_date)
    
    # Generate weights that follow a typical YouTube video view pattern
    # High initial spike, followed by gradual decline with some smaller spikes
    weights = []
    for i in range(30):
        if i == 0:  # First day spike
            weight = random.uniform(0.15, 0.25)  # 15-25% of views on first day
        elif i == 1:  # Second day
            weight = random.uniform(0.08, 0.15)  # 8-15% of views
        elif i == 2:  # Third day
            weight = random.uniform(0.05, 0.10)  # 5-10% of views
        elif i < 7:  # First week
            weight = random.uniform(0.03, 0.07)  # 3-7% of views
        elif i < 14:  # Second week
            weight = random.uniform(0.02, 0.05)  # 2-5% of views
        else:  # Rest of the month
            weight = random.uniform(0.01, 0.03)  # 1-3% of views
        
        # Add some random spikes (10% chance each day after first week)
        if i > 7 and random.random() < 0.1:
            weight *= random.uniform(1.5, 2.5)
        
        weights.append(weight)
    
    # Normalize weights to ensure they sum to 1
    total_weight = sum(weights)
    weights = [w/total_weight for w in weights]
    
    # Calculate remaining views and watchtime to distribute
    remaining_views = total_views
    remaining_watchtime = total_watchtime
    
    for i in range(30):
        metric_id = str(uuid.uuid4())
        day = (start_date + timedelta(days=i)).isoformat()
        
        # Calculate this day's share based on weight
        if i == 29:  # Last day gets all remaining values
            day_views = remaining_views
            watchtime = remaining_watchtime
        else:
            day_views = int((weights[i] / total_weight) * total_views)
            watchtime = int((weights[i] / total_weight) * total_watchtime)
            remaining_views -= day_views
            remaining_watchtime -= watchtime
        
        # Generate impressions and CTR
        # CTR tends to be higher in the first few days
        if i < 3:
            ctr_multiplier = random.uniform(2.0, 3.0)  # Higher CTR in first 3 days
        elif i < 7:
            ctr_multiplier = random.uniform(1.5, 2.0)  # Medium CTR in first week
        else:
            ctr_multiplier = random.uniform(1.2, 1.8)  # Lower CTR later
        
        impressions = int(day_views * ctr_multiplier)
        ctr = round(day_views / impressions, 4) if impressions > 0 else 0
        
        metric = {
            'metric_id': metric_id,
            'day': day,
            'day_views': day_views,
            'impressions': impressions,
            'ctr': ctr,
            'watchtime': watchtime
        }
        metrics.append(metric)
    
    return metrics

def generate_video_data(user_id):
    """Generate data for 5 videos for a user."""
    videos = []
    for i in range(5):
        video_id = str(uuid.uuid4())
        creation_date = (datetime.now() - timedelta(days=random.randint(1, 365))).isoformat()
        
        # Generate total views and watchtime
        views = random.randint(1000, 1000000)
        watchtime = random.randint(1000, 100000)
        
        # Generate other metrics
        subs = random.randint(10, 1000)
        revenue = round(views * random.uniform(0.001, 0.01), 2)
        comments = random.randint(10, 1000)
        
        video = {
            'video_id': video_id,
            'video_name': f'Video{i+1} for {user_id}',
            'views': views,
            'subs': subs,
            'revenue': revenue,
            'comments': comments,
            'watchtime': watchtime,
            'creation_date': creation_date
        }
        videos.append(video)
    return videos

def insert_data():
    """Insert all generated data into both databases."""
    # Generate users
    users = generate_user_data()
    
    # Create connections
    conn_analytics = sqlite3.connect('lib/DB/youtube_analytics.db')
    cursor_analytics = conn_analytics.cursor()
    
    conn_login = sqlite3.connect('lib/login/login_users.db')
    cursor_login = conn_login.cursor()
    
    try:
        for user in users:
            # Insert into analytics database
            cursor_analytics.execute('''
            INSERT INTO all_users (
                user_id, user_name, channel_creation_date, channel_name,
                total_views, total_subs, total_comments, total_watchtime,
                total_revenue, channel_image_link, description
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                user['user_id'], user['user_name'], user['channel_creation_date'],
                user['channel_name'], user['total_views'], user['total_subs'],
                user['total_comments'], user['total_watchtime'], user['total_revenue'],
                user['channel_image_link'], user['description']
            ))
            
            # Insert into login database
            cursor_login.execute('''
            INSERT INTO login_users (username, password)
            VALUES (?, ?)
            ''', (user['user_name'], '1234'))  # All users have password '1234'
            
            # Create user's video table
            safe_user_id = user['user_id'].replace('-', '_')
            cursor_analytics.execute(f'''
            CREATE TABLE IF NOT EXISTS user_{safe_user_id} (
                video_id TEXT PRIMARY KEY,
                video_name TEXT NOT NULL,
                views INTEGER NOT NULL,
                subs INTEGER NOT NULL,
                revenue REAL NOT NULL,
                comments INTEGER NOT NULL,
                watchtime INTEGER NOT NULL,
                creation_date TEXT NOT NULL
            )
            ''')
            
            # Generate and insert videos
            videos = generate_video_data(user['user_id'])
            total_views = 0
            total_comments = 0
            total_watchtime = 0
            total_revenue = 0.0
            
            for video in videos:
                cursor_analytics.execute(f'''
                INSERT INTO user_{safe_user_id} (
                    video_id, video_name, views, subs, revenue,
                    comments, watchtime, creation_date
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                ''', (
                    video['video_id'], video['video_name'], video['views'],
                    video['subs'], video['revenue'], video['comments'],
                    video['watchtime'], video['creation_date']
                ))
                
                # Create video metrics table
                safe_video_id = video['video_id'].replace('-', '_')
                cursor_analytics.execute(f'''
                CREATE TABLE IF NOT EXISTS video_metrics_{safe_video_id} (
                    metric_id TEXT PRIMARY KEY,
                    day TEXT NOT NULL,
                    day_views INTEGER NOT NULL,
                    impressions INTEGER NOT NULL,
                    ctr REAL NOT NULL,
                    watchtime INTEGER NOT NULL
                )
                ''')
                
                # Generate and insert metrics that sum up to the video's totals
                metrics = generate_video_metrics(
                    video['views'],
                    video['watchtime'],
                    video['creation_date']
                )
                
                for metric in metrics:
                    cursor_analytics.execute(f'''
                    INSERT INTO video_metrics_{safe_video_id} (
                        metric_id, day, day_views, impressions, ctr, watchtime
                    ) VALUES (?, ?, ?, ?, ?, ?)
                    ''', (
                        metric['metric_id'], metric['day'], metric['day_views'],
                        metric['impressions'], metric['ctr'], metric['watchtime']
                    ))
                
                total_views += video['views']
                total_comments += video['comments']
                total_watchtime += video['watchtime']
                total_revenue += video['revenue']
            
            # Update user's total stats
            cursor_analytics.execute('''
            UPDATE all_users
            SET total_views = ?, total_comments = ?, total_watchtime = ?, total_revenue = ?
            WHERE user_id = ?
            ''', (total_views, total_comments, total_watchtime, total_revenue, user['user_id']))
            
            # Commit after each user to prevent long transactions
            conn_analytics.commit()
            conn_login.commit()
    
    finally:
        # Close connections
        conn_analytics.close()
        conn_login.close()


def main():
    """Main function to generate dummy data."""
    print("Clearing existing databases...")
    clear_databases()
    
    print("Creating tables...")
    create_tables()
    
    print("Generating and inserting dummy data...")
    insert_data()
    
    print("Dummy data generation completed successfully!")

if __name__ == "__main__":
    main() 