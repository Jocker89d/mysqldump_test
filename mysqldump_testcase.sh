#!/bin/bash

#DB Creds and name
DB_USER="test_user"
DB_PASS="test_pass"
DB_NAME="test_db"

#Dump names
FULL_DUMP="/full_dump.sql"
MINIMIZED_DUMP="/minimized_dump.sql"

#Creating full db dump
mysqldump -u$DB_USER -p$DB_PASS $DB_NAME > $FULL_DUMP

#Checking if the dump created successfully
if [ $? -eq 0 ]; then
    echo "Full database dump created successfully."
else
    echo "Error: Failed to create full database dump."
    exit 1
fi

#Creating minimized db dump
cp $FULL_DUMP $MINIMIZED_DUMP
#Deleting the data for all log_* tables
awk '/CREATE TABLE/ {split($3, table, "`"); print table[2]}' $MINIMIZED_DUMP | \
while read -r table; do
    if [[ $table == log_* ]]; then
        echo "DELETE FROM $table;" >> $MINIMIZED_DUMP
    fi
done

#Checking if minimized dump is not empty
if [ -s "$MINIMIZED_DUMP" ]; then
    echo "Minimized database dump created successfully."
else
    echo "Error: Failed to create minimized database dump."
    exit 1
fi