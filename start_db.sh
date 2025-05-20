#!/bin/bash

echo "==== Starting Database Services ===="

# Execute the database initialization script
echo "Running database initialization script..."
./dal/scripts/init_main_db.sh

echo ""
echo "==== Database Initialization Complete ===="
echo ""
echo "To verify services are running, use: docker ps"
