#!/usr/bin/env python3
import os
import subprocess
import time
import sys
import signal
import atexit

# Define the base directory for the project
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
AWS_DEMO_DIR = os.path.join(BASE_DIR, "aws-demo")
SLIDES_DIR = os.path.join(BASE_DIR, "slides")

# Store process IDs for cleanup
processes = []

def cleanup():
    """Terminate all started processes on exit"""
    print("\nCleaning up processes...")
    for process in processes:
        try:
            if process.poll() is None:  # If process is still running
                process.terminate()
                print(f"Terminated process {process.pid}")
        except Exception as e:
            print(f"Error terminating process: {e}")

# Register the cleanup function to run when the script exits
atexit.register(cleanup)

def handle_signal(sig, frame):
    """Handle Ctrl+C and other signals"""
    print("\nReceived signal to terminate...")
    sys.exit(0)  # This will trigger the atexit handler

# Register signal handlers for graceful termination
signal.signal(signal.SIGINT, handle_signal)
signal.signal(signal.SIGTERM, handle_signal)

def start_service(command, cwd=None, shell=True):
    """Start a service in a new process"""
    try:
        # Using subprocess.Popen to run the command
        process = subprocess.Popen(
            command,
            cwd=cwd,
            shell=shell,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            universal_newlines=True
        )
        
        processes.append(process)
        print(f"Started process {process.pid}: {command}")
        
        # Return the process for monitoring
        return process
    except Exception as e:
        print(f"Error starting service: {e}")
        return None

def main():
    """Main function to start all services"""
    print("Starting AWS demo presentation services...")
    
    # Start Next.js app in aws-demo directory
    nextjs_process = start_service("npm run dev", cwd=AWS_DEMO_DIR)
    print("Next.js app starting at http://localhost:3001")
    
    # Give Next.js a moment to start
    time.sleep(2)
    
    # Start Convex backend in aws-demo directory
    convex_process = start_service("npx convex dev", cwd=AWS_DEMO_DIR)
    print("Convex backend starting...")
    
    # Give Convex a moment to start
    time.sleep(2)
    
    # Start Slidev in slides directory
    slidev_process = start_service("npx slidev --open", cwd=SLIDES_DIR)
    print("Slides starting at http://localhost:3030")
    
    print("\nAll services started successfully!")
    print("\nPress Ctrl+C to stop all services")
    
    # Keep the script running until user interrupts
    try:
        while True:
            # Check if any process has terminated
            for process in processes[:]:
                if process.poll() is not None:
                    print(f"Process {process.pid} exited with code {process.returncode}")
                    processes.remove(process)
            
            # If all processes have terminated, exit
            if not processes:
                print("All processes have terminated. Exiting.")
                break
                
            # Sleep to reduce CPU usage
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nReceived keyboard interrupt. Shutting down...")
        sys.exit(0)

if __name__ == "__main__":
    main() 