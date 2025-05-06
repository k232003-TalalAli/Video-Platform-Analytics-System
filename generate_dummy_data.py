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
    """Generate data for 5 users with specified usernames."""
    # List of predefined usernames
    usernames = ["umer", "Danny", "Talal", "Nemo", "Lelouch"]
    
    users = []
    for i in range(5):
        user_id = str(uuid.uuid4())
        creation_date = datetime.now().isoformat()
        username = usernames[i]
        
        user = {
            'user_id': user_id,
            'user_name': username,
            'channel_creation_date': creation_date,
            'channel_name': f'{username}\'s Channel',
            'total_views': 0,  # Will be updated after adding videos
            'total_subs': random.randint(1000, 100000),
            'total_comments': 0,  # Will be updated after adding videos
            'total_watchtime': 0,  # Will be updated after adding videos
            'total_revenue': 0.0,  # Will be updated after adding videos
            'channel_image_link': f'https://example.com/{username}.jpg',
            'description': f'Welcome to {username}\'s YouTube channel! Here you\'ll find awesome content about gaming, tech, and lifestyle.'
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

def generate_random_video_title():
    """Generate a random but meaningful video title."""
    prefixes = [
        "Ultimate Guide to", "How I Mastered", "10 Ways to Improve Your", 
        "The Secret of", "Why You Should Try", "Let's Explore", 
        "Breaking Down", "My Journey with", "The Truth About",
        "What Nobody Tells You About", "Inside the World of",
        "Beginner's Guide to", "Advanced Techniques for",
        "I Spent a Week", "24 Hours of", "Behind the Scenes of",
        "Review of", "First Look at", "Honest Opinion on",
        "The Best and Worst of", "Black", "Yay"
    ]
    
    topics = [
        "Photography", "Gaming", "Cooking", "Programming", "Hiking",
        "Fitness", "Financial Freedom", "Meditation", "Art", "Music Production",
        "Chess", "Data Science", "Machine Learning", "Cryptocurrency",
        "Woodworking", "Gardening", "Interior Design", "Martial Arts",
        "Drawing", "Animation", "Writing", "Public Speaking", "Productivity",
        "AI Tools", "Mobile Apps", "Social Media", "Digital Marketing",
        "Web Development", "Graphic Design", "Video Editing", "Man", "Watan"
    ]
    
    suffixes = [
        "in 2025", "for Beginners", "That Changed My Life", "- Full Tutorial",
        "| Step by Step Guide", "- What I Learned", "and Why It Matters",
        "- The Complete Process", "(Warning: Mind-blowing Results)",
        "- You Won't Believe What Happened", "| My Honest Experience",
        "vs Traditional Methods", "Challenge Results", "Experiment",
        "on a Budget", "Like a Pro", "in Just One Week", "Secrets Revealed",
        "That Nobody Talks About", "- Is It Worth It?", "Steal", "Hamara"
    ]
    
    return f"{random.choice(prefixes)} {random.choice(topics)} {random.choice(suffixes)}"

def generate_video_metrics(total_views, total_watchtime, creation_date):
    """Generate 30 days of metrics for a video with high variance."""
    metrics = []
    start_date = datetime.fromisoformat(creation_date)
    
    # Generate separate weights for views and watch time
    view_weights = []
    watchtime_weights = []
    
    for i in range(30):
        # Base weight for views with higher variability
        if i == 0:  # First day spike
            view_weight = random.uniform(0.1, 0.3)  # 10-30% of views on first day
        elif i == 1:  # Second day
            view_weight = random.uniform(0.05, 0.2)  # 5-20% of views
        elif i == 2:  # Third day
            view_weight = random.uniform(0.03, 0.15)  # 3-15% of views
        elif i < 7:  # First week
            view_weight = random.uniform(0.02, 0.1)  # 2-10% of views
        elif i < 14:  # Second week
            view_weight = random.uniform(0.01, 0.08)  # 1-8% of views
        else:  # Rest of the month
            view_weight = random.uniform(0.005, 0.05)  # 0.5-5% of views
        
        # Add more dramatic spikes (20% chance each day)
        if random.random() < 0.2:
            view_weight *= random.uniform(1.5, 4.0)  # Higher multiplier for more variance
        
        # Add potential dips (15% chance)
        if random.random() < 0.15:
            view_weight *= random.uniform(0.3, 0.7)  # Significant drop in views
            
        view_weights.append(view_weight)
        
        # Generate independent weight for watch time
        # Base value is partially correlated with views but with independent variance
        # Watch time pattern can differ significantly from views pattern
        watchtime_base = view_weight * random.uniform(0.5, 1.5)  # Loosely correlated with views
        
        # Add watch time specific spikes (15% chance)
        if random.random() < 0.15:
            watchtime_base *= random.uniform(1.5, 3.0)  # Higher engagement day
            
        # Add watch time specific dips (15% chance)
        if random.random() < 0.15:
            watchtime_base *= random.uniform(0.3, 0.8)  # Lower engagement day
            
        watchtime_weights.append(watchtime_base)
    
    # Normalize weights to ensure they sum to 1
    total_view_weight = sum(view_weights)
    view_weights = [w/total_view_weight for w in view_weights]
    
    total_watchtime_weight = sum(watchtime_weights)
    watchtime_weights = [w/total_watchtime_weight for w in watchtime_weights]
    
    # Calculate remaining views and watchtime to distribute
    remaining_views = total_views
    remaining_watchtime = total_watchtime
    
    for i in range(30):
        metric_id = str(uuid.uuid4())
        day = (start_date + timedelta(days=i)).isoformat()
        
        # Calculate this day's share based on independent weights
        if i == 29:  # Last day gets all remaining values
            day_views = remaining_views
            watchtime = remaining_watchtime
        else:
            day_views = int(view_weights[i] * total_views)
            watchtime = int(watchtime_weights[i] * total_watchtime)
            remaining_views -= day_views
            remaining_watchtime -= watchtime
        
        # Generate impressions and CTR with more variance
        # CTR can vary significantly day by day
        ctr_base = random.uniform(0.02, 0.12)  # Base CTR between 2% and 12%
        
        # Add random variance to CTR
        if random.random() < 0.3:  # 30% chance of a CTR spike or dip
            ctr_base *= random.uniform(0.5, 2.0)  # Can halve or double the CTR
            
        # Calculate impressions based on views and CTR
        impressions = int(day_views / ctr_base) if ctr_base > 0 else day_views * 10
        
        # Recalculate actual CTR based on views and impressions
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
    # Keep track of used titles to avoid duplicates
    used_titles = set()
    
    videos = []
    for i in range(5):
        video_id = str(uuid.uuid4())
        creation_date = (datetime.now() - timedelta(days=random.randint(1, 365))).isoformat()
        
        # Generate unique title
        while True:
            title = generate_random_video_title()
            if title not in used_titles:
                used_titles.add(title)
                break
        
        # Generate total views and watchtime with greater variance
        views = random.randint(1000, 2000000)  # Wider range
        avg_watch_minutes = random.uniform(1.5, 8.0)  # Average watch time in minutes
        watchtime = int(views * avg_watch_minutes * 60)  # Convert to seconds
        
        # Generate other metrics with greater variance
        subs_rate = random.uniform(0.005, 0.05)  # Between 0.5% and 5% of viewers subscribe
        subs = int(views * subs_rate)
        
        comment_rate = random.uniform(0.005, 0.03)  # Between 0.5% and 3% of viewers comment
        comments = int(views * comment_rate)
        
        # Revenue with more variance
        cpm = random.uniform(1.0, 8.0)  # CPM between $1 and $8
        revenue = round((views / 1000) * cpm, 2)
        
        video = {
            'video_id': video_id,
            'video_name': title,
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
            
            # Insert into login database with the new password
            cursor_login.execute('''
            INSERT INTO login_users (username, password)
            VALUES (?, ?)
            ''', (user['user_name'], 'Umer@12g'))  # New password as requested
            
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