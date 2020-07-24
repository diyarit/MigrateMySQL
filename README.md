# MigrateMySQL
Scripts for exporting and importing MySQL databases.

## Export
Interactive wizard to export the database. Exports the base in the current location and allows it to be transferred remotely with Rsync.

```bash
wget https://raw.githubusercontent.com/diyarit/MigrateMySQL/master/exportMySQL.sh -O ./exportMySQL.sh && bash ./exportMySQL.sh
```

## Import
Once exported, enter the destination server and run the following script to import the database.

```bash
wget https://raw.githubusercontent.com/diyarit/MigrateMySQL/master/importMySQL.sh -O ./importMySQL.sh && bash ./importMySQL.sh
```
