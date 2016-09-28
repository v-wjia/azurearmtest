#!/bin/bash

if [ ! -f "/usr/bin/mysql" ]; then
	yum -y install mysql
	yum -y install mysql-server
	yum -y install mysql-devel
fi
if [ ! -d "/data/mysql/data/" ]; then
	mkdir -p /data/mysql/data/
	mkdir -p /data/mysql/tmp/
fi
mkdir /var/log/mysql

config="
# The following options will be passed to all MySQL clients
[client]
#password     = your_password
port          = 3306
socket        = /tmp/mysqld.sock

# The MySQL server
[mysqld]
port                            = 3306
#basedir                         = /usr/local/mysql
datadir                         = /data/mysql/data/
socket                          = /tmp/mysqld.sock
character-set-server            = UTF8
default-storage-engine          = InnoDB
lower_case_table_names          = 1
user                            = mysql
open_files_limit                = 102400
# sql-mode                       = \"STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\"
sql-mode                        = \"NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\"
#explicit_defaults_for_timestamp = true
skip-external-locking
#skip-slave-start
#skip-name-resolve

#auto_increment_offset           = 1
#auto_increment_increment        = 2

# ============================= Network ===============================

# 在MYSQL暂时停止响应新请求之前，短时间内的多少个请求可以被存在堆栈中。如果系统在短时间内有很多连接，
# 则需要增大该参数的值，该参数值指定到来的TCP/IP连接的监听队列的大小。
# The number of outstanding connection requests MySQL can have
# 默认值 50; 范围 1 - 65535;

back_log                = 50

# MySQL允许最大的进程连接数，如果经常出现Too Many Connections的错误提示，则需要增大此值。
# The maximum permitted number of simultaneous client connections.
# 默认值 151; 范围 1 - 100000;

max_connections         = 20000

# The maximum number of simultaneous connections permitted to any given MySQL user account.
# 默认值 0; 范围 0 - 4294967295;

max_user_connections    = 0

# 设置每个主机的连接请求异常中断的最大次数，当超过该次数，MYSQL服务器将禁止host的连接请求，
# 直到mysql服务器重启或通过flush hosts命令清空此host的相关信息。
# If more than this many connection requests interrupted,the server blocks that host.

max_connect_errors      = 999999999

# connection buffer and result buffer begin with a size given by net_buffer_length,
# dynamically enlarged up to max_allowed_packet bytes as needed.The result buffer 
# shrinks to net_buffer_length after each SQL statement. 
# Default 16384; Range 1024-1048576;

net_buffer_length       = 8K

# 设置在网络传输中一次消息传输量的最大值。系统默认值 为1MB，最大值是1GB，必须设置1024的倍数。 
# The maximum size of one packet or any generated/intermediate string.
# 默认值 1048576; 范围 1024-1073741824;

max_allowed_packet      = 64M

# 指定一个请求的最大连接时间，对于4GB左右的内存服务器来说，可以将其设置为5-10。
# waits for activity on a noninteractive connection before closing it
# 默认值 28800; 范围 1 .. 2147483;

wait_timeout            = 388000

# fits client that uses the CLIENT_INTERACTIVE;
# 默认值 28800;

interactive_timeout     = 388000

# The maximum size of parameter values that can be sent with the mysql_stmt_send_long_data() C API function. 
# Default 1048576;Range 1024 .. 4294967295;

#max_long_data_size      = 1024M

# ========================== Session Thread ===========================

# 服务器线程缓存这个值表示可以重新利用保存在缓存中线程的数量,当断开连接时如果缓存中还有空间,
# 那么客户端的线程将被放到缓存中,如果线程重新被请求，那么请求将从缓存中读取,如果缓存中是空的或者是新的请求，
# 那么这个线程将被重新创建,如果有很多新的线程，增加这个值可以改善系统性能.
# 通过比较 Connections 和 Threads_created 状态的变量，可以看到这个变量的作用。
# 设置规则如下：1GB 内存配置为8，2GB配置为16，3GB配置为32，4GB或更高内存，可配置更大。
# How many threads the server should cache for reuse.
# 默认值 0; 范围 0-16384;

thread_cache_size   = 512

# 设置MYSQL每个线程的堆栈大小，默认值足够大，可满足普通操作。可设置范围为128K至4GB，默认为192KB。
# The stack size for each thread.
# 默认值 262144 (256K); 范围 131072-18446744073709547520;

thread_stack        = 512K

#thread_concurrency  = 8

# ============================ Table Cache ============================

# 指示表调整缓冲区大小。 table_cache 参数设置表高速缓存的数目。每个连接进来，都会至少打开一个表缓存。
# 因此， table_cache 的大小应与 max_connections 的设置有关。例如，对于 200 个并行运行的连接，
# 应该让表的缓存至少有 200 × N ，这里 N 是应用可以执行的查询#的一个联接中表的最大数量。
# 此外，还需要为临时表和文件保留一些额外的文件描述符。
# 当 Mysql 访问一个表时，如果该表在缓存中已经被打开，则可以直接访问缓存；如果还没有被缓存，但是在 Mysql 表缓冲区中还有空间，
# 那么这个表就被打开并放入表缓#冲区；如果表缓存满了，则会按照一定的规则将当前未用的表释放，或者临时扩大表缓存来存放，
# 使用表缓存的好处是可以更快速地访问表中的内容。执行 flush tables 会清空缓存的内容。一般来说，
# 可以通过查看数据库运行峰值时间的状态值 Open_tables 和 Opened_tables，
# 判断是否需要增加 table_cache 的值（其中 open_tables 是当前打开的表的数量， Opened_tables 则是已经打开的表的数量）。
# 即如果open_tables接近table_cache的时候，并且Opened_tables这个值在逐步增加，那就要考虑增加这个值的大小了。
# 还有就是Table_locks_waited比较高的时候，也需要增加table_cache。

#table_cache         = 1024

# The number of open tables for all threads,it requires file descriptors. 
# 默认值 400; 范围 400-524288;

table_open_cache    = 512

# 用于表间关联缓存的大小，和sort_buffer_size一样，该参数对应的分配内存也是每个连接独享。
# Default The minimum size of the buffer that is used for plain index scans, 
# range index scans, and joins that do not use indexes and thus perform full table scans.

join_buffer_size    = 32M

# sort_buffer_size 是一个connection级参数，在每个connection（session）第一次需要使用这个buffer的时候，一次性分配设置的内存。
# sort_buffer_size 并不是越大越好，由于是connection级的参数，过大的设置+高并发可能会耗尽系统内存资源。
# 例如：500个连接将会消耗 500*sort_buffer_size(8M)=4G内存
# sort_buffer_size 超过2KB的时候，就会使用mmap() 而不是 malloc() 来进行内存分配，导致效率降低。
# explain select * from table where order limit；出现filesort
# 属重点优化参数

sort_buffer_size    = 32M

query_cache_type    = OFF

table_definition_cache  = 768

table_open_cache_instances = 8

# ============================= Temptable =============================
# tmp_table_size 的默认大小是 32M。如果一张临时表超出该大小，MySQL产生一个 The table tbl_name is full 形式的错误，
# 如果你做很多高级 GROUP BY 查询，增加 tmp_table_size 值。如果超过该值，则会将临时表写入磁盘。
# The maximum size of internal in-memory temporary tables.max_tmp_tables is unused.
# Default system dependent; Range 1024-4294967295;

tmp_table_size      = 512M

# the maximum size user-created MEMORY tables are permitted to grow.
# Default 16777216; Range 16384-1844674407370954752;

max_heap_table_size = 512M

tmpdir              = /data/mysql/tmp/

# ======================= Query Specific options ======================

# 指定单个查询能够使用的缓冲区大小，缺省为1M
# Do not cache results that are larger than this number of bytes. 
# 默认值 1048576 (1M); 范围 0 .. 18446744073709547520;

#query_cache_limit              = 32M

# 默认是4KB，设置值大对大数据查询有好处，但如果你的查询都是小数据查询，就容易造成内存碎片和浪费
# 查询缓存碎片率 = Qcache_free_blocks / Qcache_total_blocks * 100%
# 如果查询缓存碎片率超过20%，可以用FLUSH QUERY CACHE整理缓存碎片，或者试试减小query_cache_min_res_unit，如果你的查询都是小数据量的话。
# 查询缓存利用率 = (query_cache_size – Qcache_free_memory) / query_cache_size * 100%
# 查询缓存利用率在25%以下的话说明query_cache_size设置的过大，可适当减小;
# 查询缓存利用率在80%以上而且Qcache_lowmem_prunes > 50的话说明query_cache_size可能有点小，要不就是碎片太多。
# 查询缓存命中率 = (Qcache_hits – Qcache_inserts) / Qcache_hits * 100%
# The minimum size (in bytes) for blocks allocated by the query cache.
# 默认值 4096; 范围 512 .. 18446744073709547520;

query_cache_min_res_unit        = 4096

# 我们首先分析一下 query_cache_size的工作原理：一个SELECT查询在DB中工作后，DB会把该语句缓存下来，
# 当同样的一个SQL再次来到DB里调用时，DB在该表没发生变化的情况下把结果从缓存中返回给Client。这里有一个关建点，
# 就是DB在利用Query_cache工作时，要求该语句涉及的表在这段时间内没有发生变更。那如果该表在发生变更时，
# Query_cache里的数据又怎么处理呢？首先要把Query_cache和该表相关的语句全部置为失效，然后在写入更新。
# 那么如果Query_cache非常大，该表的查询结构又比较多，查询语句失效也慢，一个更新或是Insert就会很慢，
# 这样看到的就是Update或是Insert怎么这么慢了。所以在数据库写入量或是更新量也比较大的系统，该参数不适合分配过大。
# 而且在高并发，写入量大的系统，建议把该功能禁掉。
# 重点优化参数（主库 增删改-MyISAM）
# The amount of memory allocated for caching query results.
# 默认值 0; 范围 0 .. 18446744073709547520;

query_cache_size                = 0

# query_cache_strip_comments     = 0

# Valid Values 0 1 2 OFF ON DEMAND; Set the query cache type.
# 默认值 1;

query_cache_type                = 1

# Setting this variable to 1 causes acquisition of a WRITE lock for a table to invalidate 
# any queries in the query cache that refer to the table.
# 默认值 FALSE;

query_cache_wlock_invalidate    = 0

# ====================== MyISAM Specific options ======================

# MySql读入缓冲区大小。对表进行顺序扫描的请求将分配一个读入缓冲区，MySql会为它分配一段内存缓冲区。
# read_buffer_size变量控制这一缓冲区的大小。如果对表的顺序扫描请求非常频繁，并且你认为频繁扫描进行得太慢，
# 可以通过增加该变量值以及内存缓冲区大小提高其性能。和sort_buffer_size一样，该参数对应的分配内存也是每个连接独享。
# Each thread that does a sequential scan for a MyISAM table allocates a buffer 
# of this size (in bytes) for each table it scans.
# 默认值 131072; 范围 8200-2147479552;

read_buffer_size            = 32M

# MySql的随机读（查询操作）缓冲区大小。当按任意顺序读取行时(例如，按照排序顺序)，将分配一个随机读缓存区。
# 进行排序查询时，MySql会首先扫描一遍该缓冲，以避免磁盘搜索，提高查询速度，如果需要排序大量数据，可适当调高该值。
# 但MySql会为每个客户连接发放该缓冲空间，所以应尽量适当设置该值，以避免内存开销过大。
# When reading rows from a MyISAM table in sorted order following a key-sorting operation, 
# the rows are read through this buffer to avoid disk seeks.
# 默认值 Default 262144; 范围 8200-4294967295;

read_rnd_buffer_size        = 32M

# 批定用于索引的缓冲区大小，增加它可以得到更好的索引处理性能，对于内存在4GB左右的服务器来说，该参数可设置为256MB或384MB。
# the size of the buffer used for MyISAM index blocks,shared by all threads.
# 默认值 8M; 范围 8-4294967295;

key_buffer_size             = 4G

# MyISAM表发生变化时重新排序所需的缓冲
# when sorting MyISAM indexes 
# 默认值 8m; 范围 4-18446744073709547520

myisam_sort_buffer_size     = 2G

# MySQL重建索引时所允许的最大临时文件的大小 (当 REPAIR, ALTER TABLE 或者 LOAD DATA INFILE).
# 如果文件大小比此值更大,索引会通过键值缓冲创建(更慢)
# while re-creating a MyISAM index 
# 默认值 2G;

myisam_max_sort_file_size   = 100G

# 如果一个表拥有超过一个索引, MyISAM 可以通过并行排序使用超过一个线程去修复他们.
# 这对于拥有多个CPU以及大量内存情况的用户,是一个很好的选择.
# Note:it is still beta-quality code. If greater than 1,indexes are created in parallel.
# 默认值 1; 范围 1-18446744073709547520 

myisam_repair_threads       = 1

# myisam_recover_options

# ====================== INNODB Specific options ======================

innodb_data_home_dir           = /data/mysql/data/

# Valid Values 0,1,2.means slow shutdown,fast shutdown,flush logs and then abort respectively
# 默认值 1;

innodb_fast_shutdown            = 1

# innodb_force_recovery

innodb_force_recovery           = 0

# 这对Innodb表来说非常重要。Innodb相比MyISAM表对缓冲更为敏感。
# MyISAM可以在默认的 key_buffer_size 设置下运行的可以，然而Innodb在默认的 innodb_buffer_pool_size 设置下却跟蜗牛似的。
# 由于Innodb把数据和索引都缓存起来，无需留给操作系统太多的内存，因此如果只需要用Innodb的话则可以设置它高达 70-80% 的可用内存。
# 一些应用于 key_buffer 的规则有 — 如果你的数据量不大，并且不会暴增，那么无需把 innodb_buffer_pool_size 设置的太大了
# The size of the memory buffer InnoDB uses to cache data and indexes of its tables. 
# 默认值 128m; 范围 1048576-2**64-1;

innodb_buffer_pool_size         = 18000M

# 此参数确定些日志文件所用的内存大小，以M为单位。缓冲区更大能提高性能，但意外的故障将会丢失数据.MySQL开发人员建议设置为1－8M之间
# The size of the buffer that InnoDB uses to write to the log files on disk. 
# 默认值 8388608; 范围 262144-4294967295;

innodb_log_buffer_size          = 64M

# 此参数确定数据日志文件的大小，以M为单位，更大的设置可以提高性能，但也会增加恢复故障数据库所需的时间
# The size in bytes of each log file in a log group.
# 默认值 5242880; 范围 108576-4294967295;

#innodb_log_file_size            = 512M

# 为提高性能，MySQL可以以循环方式将日志文件写到多个文件。推荐设置为3M
# 默认值 2; 范围 2-100;The size in bytes of each log file in a log group.

innodb_log_files_in_group       = 2

# 表空间文件 重要数据
# default behavior is to create a single 10MB auto-extending data file named ibdata1;The paths to individual data files and their sizes.;innodb_data_file_path=datafile_spec1[;datafile_spec2]...;datafile_spec=file_name:file_size[:autoextend[:max:max_file_size]]

innodb_data_file_path           = ibdata1:100M:autoextend

# Valid Values Antelope Barracuda;The file format to use for new per-table tablespace InnoDB tables.
# Default Antelope;

innodb_file_format              = Antelope

# 独享表空间（开）
# If disabled (the default),tables created in the system tablespace.If enabled,each new table create its own .ibd file.

innodb_file_per_table           = 1


# The number of I/O threads for write operations in InnoDB.
# 默认值 4; 范围 1-64;

innodb_write_io_threads         = 8

# The number of I/O threads for read operations in InnoDB.
# 默认值 4; 范围 1-64;

innodb_read_io_threads          = 8

# 20000

innodb_io_capacity              = 200

# specifies the maximum number of .ibd files that MySQL can keep open at one time. 
# independent from --open-files-limit and table cache.
# Default 300;Range 10-4294967295;

innodb_open_files               = 1024

# InnoDB中的清除操作是一类定期回收无用数据的操作。在之前的几个版本中，清除操作是主线程的一部分，这意味着运行时它可能会堵塞其它的数据库操作。
# 从MySQL5.5.X版本开始，该操作运行于独立的线程中,并支持更多的并发数。用户可通过设置innodb_purge_threads配置参数来选择清除操作是否使用单
# 独线程,默认情况下参数设置为0(不使用单独线程),设置为 1 时表示使用单独的清除线程。建议为1
# set 1 can reduce internal contention within InnoDB, improving scalability.but now the performance gain might be minimal.
# Default 0;

innodb_purge_threads            = 1

# 服务器有几个CPU就设置为几，建议用默认设置，一般为8.
# InnoDB tries to keep threads concurrently inside InnoDB less than this limit. 
# 默认值 0; 范围 0-1000;

innodb_thread_concurrency       = 0

# 如果将此参数设置为1，将在每次提交事务后将日志写入磁盘。为提供性能，可以设置为0或2，但要承担在发生故障时丢失数据的风险。
# 设置为0表示事务日志写入日志文件，而日志文件每秒刷新到磁盘一次。设置为2表示事务日志将在提交时写入日志，但日志文件每次刷新到磁盘一次。
# Valid Values 0,1,2; you should read manual for details
# 默认值 1;

innodb_flush_log_at_trx_commit  = 2

# Default fdatasync; Valid Values O_DSYNC,O_DIRECT; specify the way to open and flush files.

innodb_flush_method             = O_DIRECT

# Buffer_Pool中Dirty_Page所占的数量，直接影响InnoDB的关闭时间。
# 参数innodb_max_dirty_pages_pct 可以直接控制了Dirty_Page在Buffer_Pool中所占的比率，
# 而且幸运的是innodb_max_dirty_pages_pct是可以动态改变的。所以，在关闭InnoDB之前先将innodb_max_dirty_pages_pct调小，
# 强制数据块Flush一段时间，则能够大大缩短 MySQL关闭的时间。

innodb_max_dirty_pages_pct      = 90

# InnoDB 有其内置的死锁检测机制，能导致未完成的事务回滚。但是，如果结合InnoDB使用MyISAM的lock tables 语句或第三方事务引擎,
# 则InnoDB无法识别死锁。为消除这种可能性，可以将innodb_lock_wait_timeout设置为一个整数值，
# 指示 MySQL在允许其他事务修改那些最终受事务回滚的数据之前要等待多长时间(秒数)
# The timeout in seconds an InnoDB transaction waits for a row lock before giving up.
# 默认值 50; 范围 1-1073741824;

innodb_lock_wait_timeout        = 1000

# 这个参数用来设置 InnoDB 存储的数据目录信息和其它内部数据结构的内存池大小。应用程序里的表越多，你需要在这里分配越多的内存。
# 对于一个相对稳定的应用，这个参数的大小也是相对 稳定的，也没有必要预留非常大的值。如果 InnoDB 用光了这个池内的内存， 
# InnoDB 开始从操作系统分配内存，并且往 MySQL 错误日志写警告信息。默认值是 1MB ，当发现错误日志中已经有相关的警告信息时，
# 就应该适当的增加该参数的大小。
# The size of a memory pool InnoDB uses to store data dictionary information and other internal data structures.
# Default 8388608;Range 2097152-4294967295;

#innodb_additional_mem_pool_size = 67108864

# 用来开启innodb严格模式，在严格模式下innodb在一些条件下会直接报错，而不是发出警告或者保守处理某些语法

innodb_strict_mode                = 1

# 开启InnoDB严格检查模式，尤其是采用了页数据压缩功能时，最好是开启该功能。
# 如果语法有错误，不会有警告信息，而是直接抛出错误，好处是直接将问题扼杀在摇篮里。默认是关闭。

innodb_use_native_aio             = 1

innodb_buffer_pool_instances      = 8

# innodb_status_file              = 1

innodb_stats_on_metadata

# ================================ Log ================================

# Log errors and startup messages to this file.
# 默认值 host_name.err;

log-error                       = /var/log/mysql/error.log

# Whether to produce additional warning messages to the error log. 
# 默认值 1; 范围 0, 1, greater than 1;

#log-warnings

# Disable log-warnings

#skip-log-warnings

# Specify the initial general query log state.
# 默认值 OFF;

#general-log                     = 1

# The name of the general query log file.
# 默认值 host_name.log;

#general_log_file                = /home/mysql/logs/general.log

# Whether the slow query log is enabled
# 默认值 OFF;

#slow-query-log

# The name of the slow query log file.
# 默认值 host_name-slow.log;

#slow_query_log_file             = /home/mysql/logs/slow.log

# query longer than long_query_time seconds will be log to slow log and slow_queries status variable.
# 默认值 10;

long_query_time                 = 60

# queries that are expected to retrieve all rows are logged.
# 默认值 OFF;

#log-queries-not-using-indexes

# ==================== Replication related settings ===================
server-id                    = 1
replicate-do-db              = weixin18
#replicate-wild-do-table      =
replicate-ignore-db          = mysql
#replicate-ignore-table       =
#replicate-wild-ignore-table  =

#binlog_format  MIXED
binlog-do-db       = weixin18
binlog-ignore-db   = mysql
#binlog_cache_size  = 32K
#max_binlog_size    = 512M
sync_binlog        = 1
#innodb_support_xa  = 1
log-bin            = mysql-bin
log-bin-index      = mysql-bin.index
relay-log          = mysql-relay-bin
#relay-log-index    = mysql-relay-bin.index
#expire_logs_days   = 10
#log_slave_updates  = 1
log-slave-updates
#relay-log-purge    = 1

#slave-skip-errors=1146,1062,1050,1054,1136,1364,1051,1032

#skip-slave-start

[mysqld_safe]
log-error = /var/log/mysql/mysqld_safe.log

[mysqldump]
quick
max_allowed_packet  = 1024M

[mysql]
no-auto-rehash
# Remove the next comment character if you are not familiar with SQL
#safe-updates

default-character-set = utf8

[myisamchk]
key_buffer_size     = 20M
sort_buffer_size    = 20M
read_buffer         = 2M
write_buffer        = 2M

[mysqlhotcopy]
interactive-timeout
"

#echo mv /etc/my.cnf /etc/my.cnf.bak
#echo "$config" > /etc/my.cnf

service mysqld start
