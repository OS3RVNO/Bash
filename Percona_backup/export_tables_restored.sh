#!/bin/bash

# Configurazione
DB_NAME="db_name_restore" 
OUTPUT_FILE="/path/output_file_1.txt" LOGIN_PATH="login_file_path" # Sostituisci con il nome del tuo login path

# Trova tutte le tabelle nel database e esegui DISCARD TABLESPACE
mysql --login-path=$LOGIN_PATH -e "USE $DB_NAME; SELECT table_name FROM information_schema.tables WHERE table_schema='$DB_NAME'" | tail -n +2 > "$OUTPUT_FILE"

# Leggi il file di testo e inserisci nuovamente ogni tabella
while IFS= read -r table; do
    # Esegui il comando per inserire nuovamente la tabella
    mysql --login-path=$LOGIN_PATH -e "USE $DB_NAME; ALTER TABLE $table DISCARD TABLESPACE"
done < "$OUTPUT_FILE"
