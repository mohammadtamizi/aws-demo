# AWS Demo Presentation Tools

This repository contains automation scripts to help you launch all the components needed for the AWS deployment presentation.

## Components

1. **AWS Demo App** (Port 3001):
   - Next.js application showcasing AWS deployment
   - Convex backend for real-time data

2. **Presentation Slides** (Port 3030):
   - Slidev presentation about AWS deployment
   - Content covers containerization, Terraform, and AWS services

## Starting the Presentation

### Option 1: Using separate terminal windows (Recommended for macOS)

Run the following command:

```bash
./start_presentation_macos.py
```

This will:
- Open 3 separate Terminal windows
- Start the Next.js app in the first window
- Start the Convex backend in the second window
- Start the Slidev presentation in the third window
- Automatically open the slides in your browser

### Option 2: Single process management

Run the following command:

```bash
./start_presentation.py
```

This will:
- Start all services as background processes
- Monitor all processes in a single terminal
- Provide a clean shutdown with Ctrl+C

## Accessing the Services

- **AWS Demo App**: http://localhost:3001
- **Slides**: http://localhost:3030
- **Slides Presenter Mode**: http://localhost:3030/presenter/

## Stopping the Services

### For Option 1:
- Simply close each Terminal window or press Ctrl+C in each window

### For Option 2:
- Press Ctrl+C in the terminal where you ran the script
- All child processes will be terminated automatically

## Troubleshooting

If any service fails to start, you can start them manually:

```bash
# For the AWS Demo Next.js app
cd aws-demo && npm run dev

# For the AWS Demo Convex backend
cd aws-demo && npx convex dev

# For the slides
cd slides && npx slidev --open
``` 