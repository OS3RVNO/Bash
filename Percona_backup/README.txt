# Passaggi da seguire per esecuzione corretta di un restore

1. Preparazione del backup

A seconda della tipologia di backup da ripristinare, la preparazione del backuo con xtrabackup sarà differente.

La preparazione di un backup full avviene nel seguente modo: 
# xtrabackup --prepare --export --target-dir=/path/db_name/full

Questo comando viene utilizzato SOLO se il backup da preparare è un backup full.

La preparazione di un backup incrementale avviene nel seguente modo:

# xtrabackup --prepare --export --apply-log-only --target-dir=/path/db_name/full

# xtrabackup --prepare --apply-log-only --export --target-dir=/path/db_name/full --incremental-dir=/path/db_name/inc1   

# xtrabackup --prepare --export --target-dir=/path/db_name/full --incremental-dir=/path/db_name/inc2

Questi sono i comandi da eseguire per la preparazione di un backup incrementale, senza questi due passaggi, la preparazione del backup incrementale non va a buon fine.

ATTENZIONE: si devono applicare gli incrementali in ordine fino a quando non si raggiunge quello voluto, nell'esempio sopra, si vuole applicare il secondo incrementale.

Se si volesse preparare il terzo incrementale, si dovrà aggiungere:

# xtrabackup --prepare --export --target-dir=/path/db_name/full --incremental-dir=/path/db_name/inc3

Prima dovranno comunque essere eseguite le preparazioni degli incrementali precedenti.

2. Drop e import tablespaces 

Eseguire lo script "export_tables.sh", lo script si occuperà di eseguire il comando ALTER TABLE <table name> DISCARD TABLESPACE; per le tabelle presenti nel db scelto. 

Modificare lo script "export_tables.sh" per scegliere il database su cui eseguire le operazioni.

Copiare i file del database dal backup full (preparato con i comandi del punto precedente) nella cartella "/var/lib/mysql/db_name" (o il db preso in considerazione)

Finita la copia, modificare i permessi dei file copiati "chown -R /var/lib/mysql"

Eseguire dunque lo script "import_tables.sh" per ricreare i tablespaces correttamente nel database.

3. Restore di un database in un'altro database

Per eseguire l'operazione di ripristino dei dati di un db, in un'altro db, bisogna avere almeno un dump del db sorgente, non deve per forza essere recente.

Creare il nuovo database di destinazione, ad es. "CREATE DATABASE db_name_restored;"

Caricare il dump che sia ha a disposizione, ad es. "mysql -u root -p db_name_restored < nome_file_dump.sql"

Effettuato il caricamento del dump, eseguire "export_tables_restored.sh" (creato un file simile per comodità) per esportare i tablespaces.

Questo script, creerà un file .txt che potremo ignorare, o eventualmente tenere per un confronto.

Copiare i file del database dal backup full nella cartella del nuovo database creato(db destinazione), ad es. "/var/lib/mysql/db_name_restored"

Effettuare cambiamento permessi utente/gruppo "chown -R /var/lib/mysql"

ATTENZIONE: attualmente lo script prende in riferimento il file .txt "output_file.txt", questo file contiene le tabelle del db sorgente, il db da ripristinare nel nostro caso.

Valutare di volta in volta il contenuto di questo file.

Vanno comunque eseguite le operazioni di preparazione dei db (valutare copia dei backup per non intoccare backup originali) se si vogliono ripristinare i dati di un db in un preciso
momento.

Eseguire lo script "import_tables_restored.sh".

Fare sempre riferimento a documentazione xtrabackup per eventuali dubbi.

*Restore db: https://www.percona.com/blog/percona-xtrabackup-backup-and-restore-of-a-single-table-or-database/
*Restore istanza: https://docs.percona.com/percona-xtrabackup/8.0/restore-a-backup.html

