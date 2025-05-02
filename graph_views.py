import os
import sqlite3

import matplotlib.pyplot as plt
import pandas as pd


def get_all_users():
    """Get all users from the database."""
    conn = sqlite3.connect('lib/DB/youtube_analytics.db')
    cursor = conn.cursor()
    
    cursor.execute('SELECT user_id, user_name, channel_name FROM all_users')
    users = cursor.fetchall()
    
    conn.close()
    return users

def get_user_videos(user_id):
    """Get all videos for a specific user."""
    conn = sqlite3.connect('lib/DB/youtube_analytics.db')
    cursor = conn.cursor()
    
    safe_user_id = user_id.replace('-', '_')
    cursor.execute(f'SELECT video_id, video_name, views FROM user_{safe_user_id}')
    videos = cursor.fetchall()
    
    conn.close()
    return videos

def get_video_metrics(video_id):
    """Get all metrics for a specific video."""
    conn = sqlite3.connect('lib/DB/youtube_analytics.db')
    cursor = conn.cursor()
    
    safe_video_id = video_id.replace('-', '_')
    cursor.execute(f'''
        SELECT day, day_views 
        FROM video_metrics_{safe_video_id}
        ORDER BY day
    ''')
    metrics = cursor.fetchall()
    
    conn.close()
    return metrics

def plot_user_videos(user_id, user_name, channel_name):
    """Create a plot for all videos of a user."""
    videos = get_user_videos(user_id)
    
    # Create a figure with subplots for each video
    fig, axes = plt.subplots(len(videos), 1, figsize=(12, 4*len(videos)))
    if len(videos) == 1:
        axes = [axes]
    
    fig.suptitle(f'View Patterns for {channel_name} ({user_name})', fontsize=16)
    
    for idx, (video_id, video_name, total_views) in enumerate(videos):
        metrics = get_video_metrics(video_id)
        
        # Convert metrics to pandas DataFrame for easier handling
        df = pd.DataFrame(metrics, columns=['day', 'views'])
        df['day'] = pd.to_datetime(df['day'])
        
        # Plot the data
        ax = axes[idx]
        ax.plot(df['day'], df['views'], marker='o', linestyle='-', markersize=4)
        ax.set_title(f'{video_name} (Total Views: {total_views:,})')
        ax.set_xlabel('Date')
        ax.set_ylabel('Daily Views')
        ax.grid(True, linestyle='--', alpha=0.7)
        
        # Rotate x-axis labels for better readability
        plt.setp(ax.get_xticklabels(), rotation=45, ha='right')
    
    plt.tight_layout()
    
    # Create directory if it doesn't exist
    os.makedirs('graphs', exist_ok=True)
    
    # Save the figure
    safe_user_name = user_name.replace(' ', '_')
    plt.savefig(f'graphs/{safe_user_name}_videos.png', bbox_inches='tight', dpi=300)
    plt.close()

def plot_all_users_comparison():
    """Create a comparison plot of total views for all users."""
    conn = sqlite3.connect('lib/DB/youtube_analytics.db')
    cursor = conn.cursor()
    
    cursor.execute('SELECT user_name, channel_name, total_views FROM all_users')
    users = cursor.fetchall()
    
    conn.close()
    
    # Create the comparison plot
    plt.figure(figsize=(12, 6))
    
    # Sort users by total views
    users.sort(key=lambda x: x[2], reverse=True)
    
    # Create bar chart
    bars = plt.bar(
        [f"{user[1]}\n({user[0]})" for user in users],
        [user[2] for user in users]
    )
    
    # Add value labels on top of each bar
    for bar in bars:
        height = bar.get_height()
        plt.text(
            bar.get_x() + bar.get_width()/2.,
            height,
            f'{int(height):,}',
            ha='center',
            va='bottom'
        )
    
    plt.title('Total Views Comparison Across All Users', fontsize=16)
    plt.xlabel('Channel Name (Username)', fontsize=12)
    plt.ylabel('Total Views', fontsize=12)
    plt.xticks(rotation=45, ha='right')
    plt.grid(True, linestyle='--', alpha=0.7, axis='y')
    
    plt.tight_layout()
    
    # Save the figure
    os.makedirs('graphs', exist_ok=True)
    plt.savefig('graphs/all_users_comparison.png', bbox_inches='tight', dpi=300)
    plt.close()

def main():
    """Main function to generate all graphs."""
    print("Generating graphs...")
    
    # Get all users
    users = get_all_users()
    
    # Create individual plots for each user's videos
    for user_id, user_name, channel_name in users:
        print(f"Generating plots for {channel_name} ({user_name})...")
        plot_user_videos(user_id, user_name, channel_name)
    
    # Create comparison plot
    print("Generating comparison plot...")
    plot_all_users_comparison()
    
    print("Graph generation completed! Check the 'graphs' directory for the output files.")

if __name__ == "__main__":
    main() 