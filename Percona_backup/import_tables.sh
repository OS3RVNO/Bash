#!/bin/bash

# Configurazione
DB_NAME="redmine_002"
INPUT_FILE="/opt/gal-script/restore_db/elenco_tabelle.txt"
LOGIN_PATH="backupconn"  # Sostituisci con il nome del tuo login path
SQL_SCRIPT="/tmp/import_tablespace_script.sql"

# Creare uno script SQL temporaneo
echo "USE $DB_NAME;" > "$SQL_SCRIPT"

# Leggi il file di testo e aggiungi le istruzioni ALTER TABLE allo script SQL
while IFS= read -r table; do
    echo "ALTER TABLE $table IMPORT TABLESPACE;" >> "$SQL_SCRIPT"
done < "$INPUT_FILE"

# Esegui lo script SQL
mysql --login-path=$LOGIN_PATH -v < "$SQL_SCRIPT"

# Rimuovi lo script SQL temporaneo
rm "$SQL_SCRIPT"

