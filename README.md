

<h3 align="center">mysql-replica-prototype</h3>

<div align="center">
  <img src="https://img.shields.io/badge/status-active-success.svg" />
  <img src="https://img.shields.io/badge/MySQL-8.0.40-blue" />
</div>

---

<p align="center">A MySQL replication setup with GTID-based synchronization and data transfer using mydumper/myloader.
    <br> 
</p>

## 📝 Table of Contents
- [About](#about)
- [Getting Started](#getting-started)
- [Built Using](#built-using)

## 🧐 About <a name = "about"></a>
mysql-replica-prototype is a setup of three MySQL instances: one source and two replicas. The replicas synchronize with the source using GTID-based replication. 

This project also demonstrates the use of mydumper/myloader, a tool for efficiently copying data between databases. This is especially useful when setting up a new replica, as the initial data must be copied from the source before replication can begin.


<div style="text-align: center;">
  <img src="images/mysql-cluster-setup.svg" alt="Diagram" width="600" />
</div>


## 🏁 Getting Started <a name = "getting_started"></a>
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. 

### Prerequisites
 - [Docker](https://docs.docker.com/)
 - [Docker Compose](https://docs.docker.com/compose/)

### Installing
```bash
docker compose up
```

### Replication & Backup Cheat Sheet
#### Mydumper/Myloader

```bash
# To dump the data from the source
mydumper --host=source-db-host --user=db-user --password='password' --long-query-guard=1000  --outputdir=output-directory-of-choice --routines --triggers --compress --threads 20  --compress-protocol --trx-consistency-only --database=database-to-copy --verbose=3 -L mydumper-logs.txt

# To load the data into the new database
myloader --user=db-user --password='password' --database=database-to-load-into --threads=40 --directory=directory-where-backup-exists --verbose=3
```

#### Mysql GTID Replication

These variables must be set in the config file for both the source and replica databases:
- `server_id=unique-number`
- `log_bin=ON`
- `gtid_mode=ON`
- `enforce_gtid_consistency=ON`

##### MySQL Replication Commands Reference
```bash
# On the source server, to create a user for replication
CREATE USER 'gtid_replication_user'@'%' IDENTIFIED BY 'passs';
GRANT REPLICATION SLAVE ON *.* TO 'gtid_replication_user'@'%';

# On the Replica
STOP REPLICA;       # Stops the replication
RESET MASTER;       # Deletes all binary log files, and resets the binary log index and GTID execution history
RESET REPLICA ALL;  # Clears the replication metadata, meaning it clears the replication setup.

# On the replica, set the starting point for receiving replication events  
SET GLOBAL gtid_purged = 'GTID RANG ON MASTER WHEN THE DUMP WAS TAKEN, USUALLY IN THE DUMP META FILE';

# On the replica, to setup replication
CHANGE REPLICATION SOURCE TO
    SOURCE_HOST='db-host',
    SOURCE_PORT=3306,
    SOURCE_USER='gtid_replication_user',
    SOURCE_PASSWORD='pass',
    SOURCE_AUTO_POSITION=1;

START REPLICA;

# Troubleshooting commands to run on the replica. Provides details on the status of replication.
# If Seconds_Behind_Source = NULL, it indicates that the replication is not running.
SHOW REPLICA STATUS\G

# Troubleshooting commands to run on the replica  
# Provides details on LAST_ERROR_MESSAGE to diagnose replication issues  
SELECT * FROM PERFORMANCE_SCHEMA.REPLICATION_APPLIER_STATUS_BY_WORKER\G

# Skips a transaction on a replica and then resumes replication
SET GTID_NEXT = '12345678-aaaa-bbbb-cccc-1234567890ab:56789';   # GTID of the transaction to be skipped
BEGIN; COMMIT;
SET GTID_NEXT = 'AUTOMATIC';
START REPLICA;
```

#### Resolving Data Discrepancies with Percona Toolkit
Percona Toolkit provides two useful commands to find and fix any data differences between the master and replica databases; these commands are `pt-table-checksum` and `pt-table-sync`.

`pt-table-checksum` is used to identify the differences between the master and replica db servers, and it can be executed on a single table or on the entire database. This command generates a report, which is then used by `pt-table-sync` to resolve the differences.

`pt-table-sync` is used in the second phase after identifying which tables and rows differ between the master and replica using `pt-table-checksum`. `pt-table-sync` changes the data on the replica to match the master.

## ⛏️ Built Using <a name = "built_using"></a>
- [MySQL](https://mysql.com/) - Database Server.
- [MyDumper](https://github.com/mydumper/mydumper) - MySQL Logical Backup Tool.
- [Percona](https://docs.percona.com/percona-toolkit/index.html)

