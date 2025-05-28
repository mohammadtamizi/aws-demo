#!/usr/bin/env python3
import os
import subprocess
import time
import sys

# Define the base directory for the project
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
AWS_DEMO_DIR = os.path.join(BASE_DIR, "aws-demo")
SLIDES_DIR = os.path.join(BASE_DIR, "slides")

def open_terminal(command, title, cwd):
    """
    Open a new Terminal window on macOS with the specified command
    """
    # Escape quotes in the command
    escaped_command = command.replace('"', '\\"')

    # Create AppleScript command to open a new terminal with the specified command
    applescript = f'''
    tell application "Terminal"
        do script "cd {cwd} && {escaped_command}"
        set custom title of front window to "{title}"
        activate
    end tell
    '''

    # Execute the AppleScript
    subprocess.run(["osascript", "-e", applescript])

def main():
    """Main function to start all services in separate terminal windows"""
    print("Starting AWS demo presentation services in separate terminal windows...")

    # Start Next.js app in aws-demo directory
    open_terminal(
        "npm run dev",
        "AWS Demo - Next.js",
        AWS_DEMO_DIR
    )
    print("Next.js app starting in new terminal window")

    # Give a moment for the first window to open
    time.sleep(1)

    # Start Convex backend in aws-demo directory
    open_terminal(
        "npx convex dev",
        "AWS Demo - Convex Backend",
        AWS_DEMO_DIR
    )
    print("Convex backend starting in new terminal window")

    # Give a moment for the second window to open
    time.sleep(1)

    # Start Slidev in slides directory
    open_terminal(
        "npx slidev --open",
        "AWS Demo - Slides",
        SLIDES_DIR
    )
    print("Slides starting in new terminal window")

    print("\nAll services have been started in separate terminal windows!")
    print("To stop the services, simply close the terminal windows or press Ctrl+C in each window.")

if __name__ == "__main__":
    main()
