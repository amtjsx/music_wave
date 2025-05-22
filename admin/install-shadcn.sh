#!/bin/bash

# Initialize shadcn-ui with automatic yes to prompts
echo "Initializing shadcn-ui..."
npx shadcn@latest init -y

# Install all components with automatic yes to prompts
echo "Installing all shadcn/ui components..."
npx shadcn@latest add -a -y

echo "All shadcn/ui components have been installed successfully!"