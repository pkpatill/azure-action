#!/usr/bin/env bash

# Start
function main() {
init
chkBackupDir
}
 
function init() {
BACKUP_DIR=/path/to/backup/directory
DB_USER=db_user
DB_PASSWORD=db_password
DB_NAME=db_name
DOC_ROOT=/path/to/document/root
DAYS_TO_KEEP_BACKUP=5
}
 
function chkBackupDir() {
if [[ ! -d $BACKUP_DIR ]]; then
mkdir $BACKUP_DIR
fi
bakupDocRoot
}
 
function bakupDocRoot() {
`which tar` -cjf $BACKUP_DIR/doc_root_backup-$(date +%d-%m-%y).tar.bz2 --directory=$DOC_ROOT .
if [[ -e $BACKUP_DIR/doc_root_backup-$(date +%d-%m-%y).tar.bz2 ]]; then
bakupDatabase
else
echo Backup failed for document root on your server. Please check manually | mail -s Backup failed - Document Root user@domain.com
fi
}
 
function bakupDatabase() {
`which mysqldump` -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_DIR/$DB_NAME-$(date +%d-%m-%y).sql | tee $BACKUP_DIR/backup.log
tar -cjf $BACKUP_DIR/$DB_NAME-$(date +%d-%m-%y).tar.bz2 $BACKUP_DIR/$DB_NAME-$(date +%d-%m-%y).sql --remove-files 2> $BACKUP_DIR/tar.log
if [[ -e $BACKUP_DIR/$DB_NAME-$(date +%d-%m-%y).tar.bz2 ]]; then
createTar
else
echo Backup failed for database on your server. Please check manually | mail -s Backup failed - Database user@domain.com
fi
}
 
function createTar() {
cd $BACKUP_DIR
`which tar` -cf backup-$(date +%d-%m-%y).tar doc_root_backup-$(date +%d-%m-%y).tar.bz2 $DB_NAME-$(date +%d-%m-%y).tar.bz2 --remove-files 2> final.log
deleteOldBackup
}
 
function deleteOldBackup() {
`which find` $BACKUP_DIR/$DB_NAME* -mtime +$DAYS_TO_KEEP_BACKUP -exec rm {} \; >> $BACKUP_DIR/delete.log
}
 
main
# End
