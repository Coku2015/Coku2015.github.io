---
layout: post
title: VBR备份和恢复MySQL最佳实践
tags: MySQL, VBR, Backup
---

在Veeam数据保护平台中，对各种应用程序支持非常完善，从镜像级备份的自动应用感知到特殊的应用Plugins备份，Veeam几乎覆盖了市场上所有的主流数据的支持。然而大家经常有疑问，MySQL的备份为什么在Veeam数据保护平台中找不到身影？今天我就来说说这是怎么一回事，对于MySQL，使用Veeam应该如何做备份和恢复。

## MySQL数据存储引擎

说MySQL备份之前，得先来讲一下MySQL的数据存储引擎，因为不同的引擎直接决定了MySQL数据备份和恢复的能力。在MySQL中，默认情况下`InnoDB`是最常用的存储引擎，`Create Table`命令如果不接`Engine`参数情况下创建的表默认都会使用`InnoDB`引擎，并且Oracle官方也推荐除非有特殊需求，在通常使用MySQL时都使用`InnoDB`这个引擎。当然除了这个引擎之外，特殊情况下，MySQL也支持其他引擎，比如MyISAM、MEMORY、CSV、BLACKHOLE等引擎，关于更多的存储引擎信息，可以查看[官方文档](https://dev.mysql.com/doc/refman/8.0/en/storage-engines.html)。

InnoDB引擎的自我恢复能力非常强，目前市面上针对MySQL在线物理热备份的解决方案都是针对InnoDB引擎的恢复特性来设计的，Veeam也同样利用了这个特点来实现MySQL的数据备份。

使用InnoDB引擎的数据库在出现服务器非正常关机后，恢复数据库只需要简单的启动MySQL服务，这时候InnoDB会自动检查数据库的Redo log和undo log，进入crash recovery流程，关于这个流程的详情可以参考官网[InnoDB Recovery说明](https://dev.mysql.com/doc/refman/8.0/en/innodb-recovery.html)。这个特性对于Veeam的快照备份，无论是无代理的虚拟机快照还是Linux Agent的Veeamsnap快照来说，都非常适用，我们知道快照状态属于crash consisitent状态，这时候从这个状态启动的MySQL Server自然能非常顺利的进入自我crash recovery流程，然后完成服务启动，无需任何人工干预。

这个过程在系统恢复后，可以通过/var/log/mysql/error.log文件查询到以下信息：

```bash
[System] [MY-013576] [InnoDB] InnoDB initialization has started.
[System] [MY-013577] [InnoDB] InnoDB initialization has ended.
[System] [MY-010229] [Server] Starting XA crash recovery...
[System] [MY-010232] [Server] XA crash recovery finished.
[System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. Version: '8.0.35-0ubuntu0.20.04.1'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  (Ubuntu).
```

对于MyISAM引擎来说，因为其存储格式，也能够支持到通过物理备份的方式进行备份。唯一一点差异是，MyISAM引擎的一致性处理并不像InnoDB那么宽松，因此在物理备份复制文件之前，需要进行一个锁表的操作，来确保数据库的一致性。

## Veeam数据保护平台

#### MySQL的备份

因此，在Veeam软件中，备份MySQL数据库也需要进行分开讨论：

- InnoDB引擎 - 整个备份过程可以直接以整机的方式进行，正常执行磁盘或者文件系统的快照，在快照后将快照点的所有文件备份出来后，数据库就同时完成了备份，不需要任何额外的设置和步骤。

- MyISAM引擎 - 通常会建议加入`FLUSH TABLES tbl_list WITH READ LOCK;`命令来执行锁表操作，在锁表后MyISAM的表文件*.MYD, *.MYI, *.SDI只需要被按照文件方式备份即可。在使用无代理虚拟机快照的时候，通常会加入pre-freeze和post-unfreeze 脚本来处理锁表和解锁操作，而在使用Veeam Agent备份时，则只需要开启应用感知，那么Veeam Agent就能自动判断当前MySQL的存储引擎，自动为MyISAM引擎的表执行以上锁表和解锁操作。

数据库管理员可能这时候会疑惑，那么增量备份怎么办？备份数据有压缩吗？其实这些完全不用担心，Veeam的Change Block Tracking技术和重删压缩技术在整机镜像备份中应用的非常好，备份管理员能够轻松完成数据的重删压缩处理。

#### Veeam CDP技术在MySQL实时同步中的应用

如果您的MySQL运行在VMware vSphere中，那么恭喜您，VeeamCDP技术可以无缝应用到MySQL的实时同步复制的容灾场景中了，这时候完全不需要担心使用InnoDB引擎的MySQL的一致性，所有操作全部交给基础架构管理员托管给Veeam和VMware来完成。而在使用了Veeam B&R 12.1后，甚至还能通过文件级恢复回滚到MySQL每2秒的任意一个状态，并且对于MySQL的容灾演练来说，SureReplica技术也能在CDP副本上发挥全自动演练的作用，确保数据的可恢复性。

#### MySQL的数据恢复

通过Veeam进行备份后，MySQL的数据恢复也非常方便，可以使用的手段会非常的多。

- 整机故障 - 即时虚拟机恢复
- 数据盘故障 - 即时磁盘恢复
- DB故障 - 即时磁盘恢复、磁盘发布、文件级恢复
- 数据逻辑错误 - 结合数据实验室和文件级恢复等多种手段

## VBR中MySQL备份恢复实战

接下来我通过一个实际的例子来具体看看MySQL数据库是怎么备份和恢复的。

#### 环境说明

虚拟化平台: VMware vSphere 7.0

OS: Ubuntu 20.04

MySQL: 8.0.35

VBR: v12.1

#### 数据备份 - InnoDB

为了模拟在数据不断写入过程中的数据库热备份，我准备了一个Python脚本来每一秒插入一行时间数据。这个table非常简单，如下：

```bash
mysql> SELECT * from time LIMIT 5;
+----+------------+----------+
| id | date       | time     |
+----+------------+----------+
|  5 | 2023-12-13 | 14:06:26 |
|  6 | 2023-12-13 | 14:07:04 |
|  7 | 2023-12-13 | 14:17:14 |
|  8 | 2023-12-13 | 14:17:15 |
|  9 | 2023-12-13 | 14:17:16 |
+----+------------+----------+
5 rows in set (0.00 sec)
```

Python脚本如下：

```python
#!/usr/bin/python3
import MySQLdb
import time

while True:
    db = MySQLdb.connect("localhost", "lei", "P@ssw0rd", "leitestdb")
    curs=db.cursor()
    try:
        curs.execute ("""INSERT INTO time
                values(0, CURRENT_DATE(), NOW())""")
        db.commit()
    except:
        db.rollback()
    db.close()
    time.sleep(1)
```

VBR中的备份任务没什么特别的，一个普通的VMware虚拟机备份作业，不需要开启应用感知，直接进行备份。

![Xnip2023-12-15_11-05-43](https://s2.loli.net/2024/04/30/OkvrqPNalm5duBZ.png)

#### 数据恢复一 ：整机故障

出现了系统级的故障后，通过VBR可以执行整机的即时恢复，不仅服务器能够恢复，数据库也能完美恢复。在VBR控制台中启动即时虚拟机恢复后，MySQL能在2分钟内恢复上线。

![Xnip2023-12-15_11-27-59](https://s2.loli.net/2024/04/30/2vVCKmZdrSxEpRP.png)

我们来看看恢复后的数据库，数据库成功通过InnoDB的自我恢复模式使用crash recovery恢复。

```bash
lei@MySQL-01:~$ sudo cat /var/log/mysql/error.log
[sudo] password for lei: 
2023-12-15T03:35:54.523723Z 0 [System] [MY-010116] [Server] /usr/sbin/mysqld (mysqld 8.0.35-0ubuntu0.20.04.1) starting as process 936
2023-12-15T03:35:54.603505Z 1 [System] [MY-013576] [InnoDB] InnoDB initialization has started.
2023-12-15T03:35:55.634428Z 1 [System] [MY-013577] [InnoDB] InnoDB initialization has ended.
2023-12-15T03:35:55.892988Z 0 [System] [MY-010229] [Server] Starting XA crash recovery...
2023-12-15T03:35:55.901965Z 0 [System] [MY-010232] [Server] XA crash recovery finished.
2023-12-15T03:35:55.971499Z 0 [Warning] [MY-010068] [Server] CA certificate ca.pem is self signed.
2023-12-15T03:35:55.971547Z 0 [System] [MY-013602] [Server] Channel mysql_main configured to support TLS. Encrypted connections are now supported for this channel.
2023-12-15T03:35:56.039984Z 0 [System] [MY-011323] [Server] X Plugin ready for connections. Bind-address: '127.0.0.1' port: 33060, socket: /var/run/mysqld/mysqlx.sock
2023-12-15T03:35:56.040153Z 0 [System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. Version: '8.0.35-0ubuntu0.20.04.1'  socket: '/var/run/mysqld/mysqld.sock'  port: 3306  (Ubuntu).
```

我们再来看看备份的数据点位于哪个时间点：

```bash
mysql> select * from time order by id desc LIMIT 10;
+-----+------------+----------+
| id  | date       | time     |
+-----+------------+----------+
| 361 | 2023-12-14 | 10:20:00 |
| 360 | 2023-12-14 | 10:19:59 |
| 359 | 2023-12-14 | 10:19:58 |
| 358 | 2023-12-14 | 10:19:57 |
| 357 | 2023-12-14 | 10:19:56 |
| 356 | 2023-12-14 | 10:19:55 |
| 355 | 2023-12-14 | 10:19:54 |
| 354 | 2023-12-14 | 10:19:53 |
| 353 | 2023-12-14 | 10:19:52 |
| 352 | 2023-12-14 | 10:19:51 |
+-----+------------+----------+
10 rows in set (0.00 sec)
```

可以看到，备份数据的最后一条记录在2023-12-14的10:20:00写入，而前面备份时的虚拟机快照完成时间正好是10:20:21。

#### 数据恢复二：MySQL数据整库恢复

这个场景多数出现于主机环境正常，而数据库出现了问题，这时候在Veeam中恢复的操作方法选择也非常多样。我们先来看看从备份管理员角度最舒服的操作方式：Veeam文件级恢复。

找到VBR控制台的MySQL存档，在右键菜单中，选择`Restore guest files-> Linux and other...`，就能打开MySQL的文件级还原向导。

![Xnip2023-12-15_11-55-18](https://s2.loli.net/2024/04/30/9FeNr1aqn3JsSR2.png)

打开后，在图形化恢复界面中，可以快速找到/var/lib/mysql的数据目录，看到其中的详细每一个文件。

![Xnip2023-12-15_12-46-34](https://s2.loli.net/2024/04/30/DeLOSm9yTN74r8Y.png)

选择文件或者目录后，把/var/lib/mysql整个目录还原回源机或者新服务器，即可完成数据还原。完成数据还原后，在MySQL服务器上，检查下目录的权限，如果owner和group不正确，就通过以下命令调整一下权限，然后启动mysql即可。

```bash
$ chown -R mysql:mysql /var/lib/mysql
```

#### 数据恢复三：单表恢复

单表恢复在MySQL中会比较复杂一点，但是利用Veeam的强大功能，我们可以轻松实现。具体原理，还是基于[MySQL 官网的InnoDB引擎的恢复说明](https://dev.mysql.com/doc/refman/8.2/en/innodb-table-import.html)

首先，我们需要用数据实验室生成一份要恢复表的metadata，关于数据实验室的配置，可以参考我之前的帖子。

在数据实验室中，MySQL机器能够正常被启动，我们通过ssh连接进入机器，然后执行mysql命令来生成metadata：

```bash
mysql> use leitestdb;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> FLUSH TABLES time FOR EXPORT;
Query OK, 0 rows affected (0.00 sec)
```

这时候，需要注意的是，暂时还不能退出mysql控制台，我们需要先将生成的time.cfg文件拷贝出来，存放备用。因为退出mysql控制台后，这个文件就被自动删除了。

接着，我们开始正式恢复单表数据。

要恢复MySQL的单个表，首先我们需要在数据库里把表结构创建一下，比如我的这张表如下：

```sql
mysql> CREATE TABLE `time` (
  `id` int(11) NOT NULL AUTO_INCREMENT, 
  `date` date DEFAULT NULL, 
  `time` time DEFAULT NULL, 
  PRIMARY KEY (`id`) 
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
```

然后我们用discard命令丢弃下这个表的表空间：

```bash
mysql> ALTER TABLE time DISCARD TABLESPACE;
Query OK, 0 rows affected (0.00 sec)
```

接着，我们找到备份数据中的time.idb文件，如图做一个单文件的文件级恢复：

![Xnip2023-12-15_13-18-21](https://s2.loli.net/2024/04/30/oB7DGvRSsH1tIld.png)

恢复至对应的数据库目录下以后，VBR中能够看到恢复成功信息如图：

![Xnip2023-12-15_13-22-49](https://s2.loli.net/2024/04/30/nfOeQsgo5X8w2rF.png)

然后我们需要将刚刚从数据实验室中取出来的time.cfg文件一样还原至/var/lib/mysql/leitestdb/目录下，确保还原后该目录下内容如下：

```bash
root@MySQL-01:~# ls -ahl /var/lib/mysql/leitestdb/
total 120K
drwxr-x--- 2 mysql mysql   38 Dec 15 14:07 .
drwx------ 8 mysql mysql 4.0K Dec 15 00:00 ..
-rw-r----- 1 mysql mysql  772 Dec 15 13:55 time.cfg
-rw-r----- 1 mysql mysql 112K Dec 13 15:00 time.ibd
```

回到MySQL控制台，我们再用Import命令导入下刚刚恢复的表空间。

```bash
mysql> ALTER TABLE time IMPORT TABLESPACE;
Query OK, 0 rows affected (0.01 sec)
```

查询下数据看看：

```bash
mysql> SELECT * from time order by id desc LIMIT 5;
+-----+------------+----------+
| id  | date       | time     |
+-----+------------+----------+
| 341 | 2023-12-14 | 10:19:40 |
| 320 | 2023-12-13 | 14:48:22 |
| 319 | 2023-12-13 | 14:48:22 |
| 318 | 2023-12-13 | 14:48:22 |
| 317 | 2023-12-13 | 14:48:22 |
+-----+------------+----------+
5 rows in set (0.00 sec)
```

可以看到这个表已经被恢复了，和前面整机恢复的稍有不同，因为镜像级备份的表数据并不包含redo.log和undo.log中的数据，因此这种表恢复会丢失一些还未被commit的数据。



#### 数据恢复四：Point-in-time恢复

在VBR备份时，我们备份了整个机器包含了MySQL的整个数据目录，因此每次镜像级备份会同样将mysql binlog一起备份下来。通过文件级恢复或者磁盘发布命令，我们能够很轻松的读取到备份中的数据。

接下来，我们来试试v12.1中的新功能：虚拟磁盘发布。

在VBR控制台中找到MySQL的存档，右键恢复菜单中，能看到`Publish Disks`选项。

![Xnip2023-12-15_14-23-16](https://s2.loli.net/2024/04/30/tThSMQcxEGmsoqi.png)

简单跟着向导输入一些目标机器的信息，磁盘就能备发布挂载至对应的Linux服务器的/tmp目录下了。

![Xnip2023-12-15_14-26-00](https://s2.loli.net/2024/04/30/hkx9fitlWgzeuBO.png)

我们回到MySQL服务器上，进入这个目录看一看

```bash
lei@MySQL-01:~$ ls -ahl /tmp/Veeam.Mount.FS.54290a8a-a833-4a0e-8c43-2715b07795df/
total 4.0K
drwxr-xr-x  3 root root   33 Dec 15 14:25 .
drwxrwxrwt 18 root root 4.0K Dec 15 14:25 ..
drwxr-xr-x 19 root root  292 Apr  4  2022 ubuntu-vg-ubuntu-lv
lei@MySQL-01:~$ cd /tmp/Veeam.Mount.FS.54290a8a-a833-4a0e-8c43-2715b07795df/
lei@MySQL-01:/tmp/Veeam.Mount.FS.54290a8a-a833-4a0e-8c43-2715b07795df$ cd ubuntu-vg-ubuntu-lv/
lei@MySQL-01:/tmp/Veeam.Mount.FS.54290a8a-a833-4a0e-8c43-2715b07795df/ubuntu-vg-ubuntu-lv$ ls
bin   cdrom  etc   lib    lib64   media  opt   root  sbin  srv       sys  usr
boot  dev    home  lib32  libx32  mnt    proc  run   snap  swap.img  tmp  var
lei@MySQL-01:/tmp/Veeam.Mount.FS.54290a8a-a833-4a0e-8c43-2715b07795df/ubuntu-vg-ubuntu-lv$ ls -ahl /var/lib/mysql/
ls: cannot open directory '/var/lib/mysql/': Permission denied
lei@MySQL-01:/tmp/Veeam.Mount.FS.54290a8a-a833-4a0e-8c43-2715b07795df/ubuntu-vg-ubuntu-lv$ sudo -i ls -ahl /var/lib/mysql/
[sudo] password for lei: 
total 90M
drwx------  8 mysql mysql 4.0K Dec 15 00:00  .
drwxr-xr-x 48 root  root  4.0K Dec 15 10:57  ..
-rw-r-----  1 mysql mysql   56 Dec 13 11:11  auto.cnf
-rw-r-----  1 mysql mysql  180 Dec 13 11:12  binlog.000001
-rw-r-----  1 mysql mysql  404 Dec 13 11:12  binlog.000002
-rw-r-----  1 mysql mysql  17K Dec 13 14:26  binlog.000003
-rw-r-----  1 mysql mysql 5.2K Dec 13 14:31  binlog.000004
-rw-r-----  1 mysql mysql  75K Dec 13 14:48  binlog.000005
-rw-r-----  1 mysql mysql  157 Dec 13 15:01  binlog.000006
-rw-r-----  1 mysql mysql  26K Dec 15 00:00  binlog.000007
-rw-r-----  1 mysql mysql 2.1K Dec 15 14:07  binlog.000008
-rw-r-----  1 mysql mysql  128 Dec 15 00:00  binlog.index
-rw-------  1 mysql mysql 1.7K Dec 13 11:11  ca-key.pem
-rw-r--r--  1 mysql mysql 1.1K Dec 13 11:11  ca.pem
-rw-r--r--  1 mysql mysql 1.1K Dec 13 11:11  client-cert.pem
-rw-------  1 mysql mysql 1.7K Dec 13 11:11  client-key.pem
-rw-r--r--  1 root  root     0 Dec 13 11:12  debian-5.7.flag
-rw-r-----  1 mysql mysql 192K Dec 15 14:09 '#ib_16384_0.dblwr'
-rw-r-----  1 mysql mysql 8.2M Dec 15 14:07 '#ib_16384_1.dblwr'
-rw-r-----  1 mysql mysql 3.6K Dec 13 14:26  ib_buffer_pool
-rw-r-----  1 mysql mysql  12M Dec 15 14:07  ibdata1
-rw-r-----  1 mysql mysql  12M Dec 13 15:01  ibtmp1
drwxr-x---  2 mysql mysql 4.0K Dec 13 15:01 '#innodb_redo'
drwxr-x---  2 mysql mysql  187 Dec 13 15:01 '#innodb_temp'
drwxr-x---  2 mysql mysql   38 Dec 15 14:07  leitestdb
drwxr-x---  2 mysql mysql  143 Dec 13 11:11  mysql
-rw-r-----  1 mysql mysql    4 Dec 13 15:01  MySQL-01.pid
-rw-r-----  1 mysql mysql  25M Dec 15 14:07  mysql.ibd
drwxr-x---  2 mysql mysql 8.0K Dec 13 11:11  performance_schema
-rw-------  1 mysql mysql 1.7K Dec 13 11:11  private_key.pem
-rw-r--r--  1 mysql mysql  452 Dec 13 11:11  public_key.pem
-rw-r--r--  1 mysql mysql 1.1K Dec 13 11:11  server-cert.pem
-rw-------  1 mysql mysql 1.7K Dec 13 11:11  server-key.pem
drwxr-x---  2 mysql mysql   28 Dec 13 11:11  sys
-rw-r-----  1 mysql mysql  16M Dec 15 14:09  undo_001
-rw-r-----  1 mysql mysql  16M Dec 15 14:09  undo_002
lei@MySQL-01:/tmp/Veeam.Mount.FS.54290a8a-a833-4a0e-8c43-2715b07795df/ubuntu-vg-ubuntu-lv$ 
```

在这里，我们能够看到所有的文件都已经被mount上来了，接下去，我们只需要用常规的Linux cp命令，就能提取相关的binlog文件进行数据恢复啦。

在恢复结束后，不要忘记在VBR中取消磁盘发布。

![Xnip2023-12-15_14-31-01](https://s2.loli.net/2024/04/30/CfVnmJ69c3LUYo8.png)

## 总结

使用Veeam进行MySQL备份时，如果您的环境只有InnoDB引擎，那么这时候您完全不需要考虑任何备份过程的特殊处理操作，直接用镜像级的快照备份就能完美处理各种MySQL的备份和恢复场景；而当您的环境中有MyISAM引擎时，可以有两种选择，一种是使用Veeam Agent的方式由Veeam Agent来做锁表和解锁操作，另外一种您可以通过虚拟机备份应用感知中的脚本功能，在快照前后来手工加入锁表和解锁操作；而当您的环境中有其他类型的存储引擎时，我建议您最好通过暂停数据库的脚本通过冷备份的方式来进行，这样虽然会带来分钟级的短暂停机但是能确保数据的一致性。

以上就是Veeam备份恢复MySQL的最佳实践，欢迎关注我的博客，了解更多Veeam的备份技术。
