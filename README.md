

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
mydumper --host=db-host --user=db-user --password='password' --long-query-guard=1000  --outputdir=output-directory-of-choice --routines --triggers --compress --threads 20  --compress-protocol --trx-consistency-only --database=database-to-copy --verbose=3 -L mydumper-logs.txt

myloader --user=db-user --password='password' --database=database-to-load-into --threads=40 --directory=directory-where-backup-exists --verbose=3
```

#### GTID Replication

These variables have to be set in the config file: 
- server_id=unique-number
- log_bin=ON
- gtid_mode=ON
- enforce_gtid_consistency=ON


Mysql commands
```bash
# On the master
CREATE USER 'gtid_replication_user'@'%' IDENTIFIED BY 'pass';
GRANT REPLICATION SLAVE ON *.* TO 'gtid_replication_user'@'%';

# On the Replica
STOP REPLICA;
RESET MASTER;
RESET SLAVE ALL;

SET GLOBAL gtid_purged = 'GTID RANG ON MASTER WHEN THE DUMP WAS TAKEN, USUALLY IN THE DUMP META FILE';

CHANGE REPLICATION SOURCE TO
    SOURCE_HOST='db-host',
    SOURCE_PORT=3306,
    SOURCE_USER='gtid_replication_user',
    SOURCE_PASSWORD='pass',
    SOURCE_AUTO_POSITION=1;

START REPLICA;
SHOW REPLICA STATUS\G
```

## ⛏️ Built Using <a name = "built_using"></a>
- [MySQL](https://mysql.com/) - Database Server.
- [MyDumper](https://github.com/mydumper/mydumper) - MySQL Logical Backup Tool.
