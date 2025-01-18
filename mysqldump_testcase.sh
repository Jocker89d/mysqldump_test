#!/bin/bash

#DB Creds and name
DB_USER="test_user"
DB_PASS="test_pass"
DB_NAME="test_db"

#Dump names
FULL_DUMP="/full_dump.sql"
MINIMIZED_DUMP="/minimized_dump.sql"

#Setting transaction isolation level
mysql -u$DB_USER -p$DB_PASS -D $DB_NAME -e "SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;"

#Creating full db dump and compressing it
mysqldump --single-transaction -u$DB_USER -p$DB_PASS $DB_NAME | gzip > $FULL_DUMP

#Checking if the dump created successfully
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "Full database dump created successfully."
else
    echo "Error: Failed to create full database dump."
    exit 1
fi

#Creating minimized db dump
zcat $FULL_DUMP > $MINIMIZED_DUMP

#Deleting all insert into statements for log_ tables from minimized dump
sed -i '/^INSERT INTO .*log_/d' $MINIMIZED_DUMP

#Compressing minimized dump
gzip $MINIMIZED_DUMP

#Checking if minimized dump is not empty
if [ -s "$MINIMIZED_DUMP.gz" ]; then
    echo "Minimized database dump created successfully."
else
    echo "Error: Failed to create minimized database dump."
    exit 1
fi

echo "done"