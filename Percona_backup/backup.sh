#!/bin/bash

# Configurazioni
DATABASES=("redmine_002")  # Aggiungi i tuoi nomi di database
BACKUP_DIR="/opt/gal-script/test"
LOG_FILE="$BACKUP_DIR/backup.log"

# Funzione per creare la cartella se non esiste
create_directory() {
  local dir=$1
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
  fi
}

# Funzione per eseguire il backup completo
perform_full_backup() {
  local db=$1
  local target_dir="$BACKUP_DIR/$db/full"
  
  create_directory "$target_dir"
  
  xtrabackup --login-path="backupconn" --backup --target-dir="$target_dir" --export --databases="$db" >> "$LOG_FILE" 2>&1
}

# Funzione per eseguire il primo backup incrementale
perform_first_incremental_backup() {
  local db=$1
  local target_dir="$BACKUP_DIR/$db/inc1"
  local full_backup_dir="$BACKUP_DIR/$db/full"

  create_directory "$target_dir"

  xtrabackup --login-path="backupconn" --backup --target-dir="$target_dir" --export --databases="$db" --incremental-basedir="$full_backup_dir" >> "$LOG_FILE" 2>&1
}

# Funzione per eseguire gli incrementali successivi al primo
perform_subsequent_incremental_backup() {
  local db=$1
  local incremental_num=$2
  local target_dir="$BACKUP_DIR/$db/inc$incremental_num"
  local previous_incremental_dir="$BACKUP_DIR/$db/inc$((incremental_num - 1))"

  create_directory "$target_dir"

  xtrabackup --login-path="backupconn" --backup --target-dir="$target_dir" --export --databases="$db" --incremental-basedir="$previous_incremental_dir" >> "$LOG_FILE" 2>&1
}

# Verifica i parametri
if [ "$#" -ne 1 ]; then
  echo "Uso: $0 <tipo_backup>"
  echo "Esempio: $0 incremental"
  exit 1
fi

# Crea la cartella principale se non esiste
create_directory "$BACKUP_DIR"

backup_type=$1

# Esegui backup per i database specificati
for db in "${DATABASES[@]}"; do
  if [ "$backup_type" == "full" ]; then
    perform_full_backup "$db"
  elif [ "$backup_type" == "incremental" ]; then
    # Controlla se è il primo backup incrementale
    if [ ! -d "$BACKUP_DIR/$db/inc1" ]; then
      perform_first_incremental_backup "$db"
    else
      # Trova l'ultimo backup incrementale
      latest_incremental=$(find "$BACKUP_DIR/$db" -type d -name "inc*" | sort -r | head -n 1)
      incremental_num=${latest_incremental##*inc}
      incremental_num=$((incremental_num + 1))

      perform_subsequent_incremental_backup "$db" "$incremental_num"
    fi
  else
    echo "Tipo di backup non valido: $backup_type"
    exit 1
  fi
done

