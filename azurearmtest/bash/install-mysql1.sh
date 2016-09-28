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

# ��MYSQL��ʱֹͣ��Ӧ������֮ǰ����ʱ���ڵĶ��ٸ�������Ա����ڶ�ջ�С����ϵͳ�ڶ�ʱ�����кܶ����ӣ�
# ����Ҫ����ò�����ֵ���ò���ֵָ��������TCP/IP���ӵļ������еĴ�С��
# The number of outstanding connection requests MySQL can have
# Ĭ��ֵ 50; ��Χ 1 - 65535;

back_log                = 50

# MySQL�������Ľ����������������������Too Many Connections�Ĵ�����ʾ������Ҫ�����ֵ��
# The maximum permitted number of simultaneous client connections.
# Ĭ��ֵ 151; ��Χ 1 - 100000;

max_connections         = 20000

# The maximum number of simultaneous connections permitted to any given MySQL user account.
# Ĭ��ֵ 0; ��Χ 0 - 4294967295;

max_user_connections    = 0

# ����ÿ�����������������쳣�жϵ����������������ô�����MYSQL����������ֹhost����������
# ֱ��mysql������������ͨ��flush hosts������մ�host�������Ϣ��
# If more than this many connection requests interrupted,the server blocks that host.

max_connect_errors      = 999999999

# connection buffer and result buffer begin with a size given by net_buffer_length,
# dynamically enlarged up to max_allowed_packet bytes as needed.The result buffer 
# shrinks to net_buffer_length after each SQL statement. 
# Default 16384; Range 1024-1048576;

net_buffer_length       = 8K

# ���������紫����һ����Ϣ�����������ֵ��ϵͳĬ��ֵ Ϊ1MB�����ֵ��1GB����������1024�ı����� 
# The maximum size of one packet or any generated/intermediate string.
# Ĭ��ֵ 1048576; ��Χ 1024-1073741824;

max_allowed_packet      = 64M

# ָ��һ��������������ʱ�䣬����4GB���ҵ��ڴ��������˵�����Խ�������Ϊ5-10��
# waits for activity on a noninteractive connection before closing it
# Ĭ��ֵ 28800; ��Χ 1 .. 2147483;

wait_timeout            = 388000

# fits client that uses the CLIENT_INTERACTIVE;
# Ĭ��ֵ 28800;

interactive_timeout     = 388000

# The maximum size of parameter values that can be sent with the mysql_stmt_send_long_data() C API function. 
# Default 1048576;Range 1024 .. 4294967295;

#max_long_data_size      = 1024M

# ========================== Session Thread ===========================

# �������̻߳������ֵ��ʾ�����������ñ����ڻ������̵߳�����,���Ͽ�����ʱ��������л��пռ�,
# ��ô�ͻ��˵��߳̽����ŵ�������,����߳����±�������ô���󽫴ӻ����ж�ȡ,����������ǿյĻ������µ�����
# ��ô����߳̽������´���,����кܶ��µ��̣߳��������ֵ���Ը���ϵͳ����.
# ͨ���Ƚ� Connections �� Threads_created ״̬�ı��������Կ���������������á�
# ���ù������£�1GB �ڴ�����Ϊ8��2GB����Ϊ16��3GB����Ϊ32��4GB������ڴ棬�����ø���
# How many threads the server should cache for reuse.
# Ĭ��ֵ 0; ��Χ 0-16384;

thread_cache_size   = 512

# ����MYSQLÿ���̵߳Ķ�ջ��С��Ĭ��ֵ�㹻�󣬿�������ͨ�����������÷�ΧΪ128K��4GB��Ĭ��Ϊ192KB��
# The stack size for each thread.
# Ĭ��ֵ 262144 (256K); ��Χ 131072-18446744073709547520;

thread_stack        = 512K

#thread_concurrency  = 8

# ============================ Table Cache ============================

# ָʾ�������������С�� table_cache �������ñ���ٻ������Ŀ��ÿ�����ӽ������������ٴ�һ�����档
# ��ˣ� table_cache �Ĵ�СӦ�� max_connections �������йء����磬���� 200 ���������е����ӣ�
# Ӧ���ñ�Ļ��������� 200 �� N ������ N ��Ӧ�ÿ���ִ�еĲ�ѯ#��һ�������б�����������
# ���⣬����ҪΪ��ʱ����ļ�����һЩ������ļ���������
# �� Mysql ����һ����ʱ������ñ��ڻ������Ѿ����򿪣������ֱ�ӷ��ʻ��棻�����û�б����棬������ Mysql �������л��пռ䣬
# ��ô�����ͱ��򿪲������#����������������ˣ���ᰴ��һ���Ĺ��򽫵�ǰδ�õı��ͷţ�������ʱ�����������ţ�
# ʹ�ñ���ĺô��ǿ��Ը����ٵط��ʱ��е����ݡ�ִ�� flush tables ����ջ�������ݡ�һ����˵��
# ����ͨ���鿴���ݿ����з�ֵʱ���״ֵ̬ Open_tables �� Opened_tables��
# �ж��Ƿ���Ҫ���� table_cache ��ֵ������ open_tables �ǵ�ǰ�򿪵ı�������� Opened_tables �����Ѿ��򿪵ı����������
# �����open_tables�ӽ�table_cache��ʱ�򣬲���Opened_tables���ֵ�������ӣ��Ǿ�Ҫ�����������ֵ�Ĵ�С�ˡ�
# ���о���Table_locks_waited�Ƚϸߵ�ʱ��Ҳ��Ҫ����table_cache��

#table_cache         = 1024

# The number of open tables for all threads,it requires file descriptors. 
# Ĭ��ֵ 400; ��Χ 400-524288;

table_open_cache    = 512

# ���ڱ���������Ĵ�С����sort_buffer_sizeһ�����ò�����Ӧ�ķ����ڴ�Ҳ��ÿ�����Ӷ���
# Default The minimum size of the buffer that is used for plain index scans, 
# range index scans, and joins that do not use indexes and thus perform full table scans.

join_buffer_size    = 32M

# sort_buffer_size ��һ��connection����������ÿ��connection��session����һ����Ҫʹ�����buffer��ʱ��һ���Է������õ��ڴ档
# sort_buffer_size ������Խ��Խ�ã�������connection���Ĳ��������������+�߲������ܻ�ľ�ϵͳ�ڴ���Դ��
# ���磺500�����ӽ������� 500*sort_buffer_size(8M)=4G�ڴ�
# sort_buffer_size ����2KB��ʱ�򣬾ͻ�ʹ��mmap() ������ malloc() �������ڴ���䣬����Ч�ʽ��͡�
# explain select * from table where order limit������filesort
# ���ص��Ż�����

sort_buffer_size    = 32M

query_cache_type    = OFF

table_definition_cache  = 768

table_open_cache_instances = 8

# ============================= Temptable =============================
# tmp_table_size ��Ĭ�ϴ�С�� 32M�����һ����ʱ�����ô�С��MySQL����һ�� The table tbl_name is full ��ʽ�Ĵ���
# ��������ܶ�߼� GROUP BY ��ѯ������ tmp_table_size ֵ�����������ֵ����Ὣ��ʱ��д����̡�
# The maximum size of internal in-memory temporary tables.max_tmp_tables is unused.
# Default system dependent; Range 1024-4294967295;

tmp_table_size      = 512M

# the maximum size user-created MEMORY tables are permitted to grow.
# Default 16777216; Range 16384-1844674407370954752;

max_heap_table_size = 512M

tmpdir              = /data/mysql/tmp/

# ======================= Query Specific options ======================

# ָ��������ѯ�ܹ�ʹ�õĻ�������С��ȱʡΪ1M
# Do not cache results that are larger than this number of bytes. 
# Ĭ��ֵ 1048576 (1M); ��Χ 0 .. 18446744073709547520;

#query_cache_limit              = 32M

# Ĭ����4KB������ֵ��Դ����ݲ�ѯ�кô����������Ĳ�ѯ����С���ݲ�ѯ������������ڴ���Ƭ���˷�
# ��ѯ������Ƭ�� = Qcache_free_blocks / Qcache_total_blocks * 100%
# �����ѯ������Ƭ�ʳ���20%��������FLUSH QUERY CACHE��������Ƭ���������Լ�Сquery_cache_min_res_unit�������Ĳ�ѯ����С�������Ļ���
# ��ѯ���������� = (query_cache_size �C Qcache_free_memory) / query_cache_size * 100%
# ��ѯ������������25%���µĻ�˵��query_cache_size���õĹ��󣬿��ʵ���С;
# ��ѯ������������80%���϶���Qcache_lowmem_prunes > 50�Ļ�˵��query_cache_size�����е�С��Ҫ��������Ƭ̫�ࡣ
# ��ѯ���������� = (Qcache_hits �C Qcache_inserts) / Qcache_hits * 100%
# The minimum size (in bytes) for blocks allocated by the query cache.
# Ĭ��ֵ 4096; ��Χ 512 .. 18446744073709547520;

query_cache_min_res_unit        = 4096

# �������ȷ���һ�� query_cache_size�Ĺ���ԭ��һ��SELECT��ѯ��DB�й�����DB��Ѹ���仺��������
# ��ͬ����һ��SQL�ٴ�����DB�����ʱ��DB�ڸñ�û�����仯������°ѽ���ӻ����з��ظ�Client��������һ���ؽ��㣬
# ����DB������Query_cache����ʱ��Ҫ�������漰�ı������ʱ����û�з��������������ñ��ڷ������ʱ��
# Query_cache�����������ô�����أ�����Ҫ��Query_cache�͸ñ���ص����ȫ����ΪʧЧ��Ȼ����д����¡�
# ��ô���Query_cache�ǳ��󣬸ñ�Ĳ�ѯ�ṹ�ֱȽ϶࣬��ѯ���ʧЧҲ����һ�����»���Insert�ͻ������
# ���������ľ���Update����Insert��ô��ô���ˡ����������ݿ�д�������Ǹ�����Ҳ�Ƚϴ��ϵͳ���ò������ʺϷ������
# �����ڸ߲�����д�������ϵͳ������Ѹù��ܽ�����
# �ص��Ż����������� ��ɾ��-MyISAM��
# The amount of memory allocated for caching query results.
# Ĭ��ֵ 0; ��Χ 0 .. 18446744073709547520;

query_cache_size                = 0

# query_cache_strip_comments     = 0

# Valid Values 0 1 2 OFF ON DEMAND; Set the query cache type.
# Ĭ��ֵ 1;

query_cache_type                = 1

# Setting this variable to 1 causes acquisition of a WRITE lock for a table to invalidate 
# any queries in the query cache that refer to the table.
# Ĭ��ֵ FALSE;

query_cache_wlock_invalidate    = 0

# ====================== MyISAM Specific options ======================

# MySql���뻺������С���Ա����˳��ɨ������󽫷���һ�����뻺������MySql��Ϊ������һ���ڴ滺������
# read_buffer_size����������һ�������Ĵ�С������Ա��˳��ɨ������ǳ�Ƶ������������ΪƵ��ɨ����е�̫����
# ����ͨ�����Ӹñ���ֵ�Լ��ڴ滺������С��������ܡ���sort_buffer_sizeһ�����ò�����Ӧ�ķ����ڴ�Ҳ��ÿ�����Ӷ���
# Each thread that does a sequential scan for a MyISAM table allocates a buffer 
# of this size (in bytes) for each table it scans.
# Ĭ��ֵ 131072; ��Χ 8200-2147479552;

read_buffer_size            = 32M

# MySql�����������ѯ��������������С����������˳���ȡ��ʱ(���磬��������˳��)��������һ���������������
# ���������ѯʱ��MySql������ɨ��һ��û��壬�Ա��������������߲�ѯ�ٶȣ������Ҫ����������ݣ����ʵ����߸�ֵ��
# ��MySql��Ϊÿ���ͻ����ӷ��Ÿû���ռ䣬����Ӧ�����ʵ����ø�ֵ���Ա����ڴ濪������
# When reading rows from a MyISAM table in sorted order following a key-sorting operation, 
# the rows are read through this buffer to avoid disk seeks.
# Ĭ��ֵ Default 262144; ��Χ 8200-4294967295;

read_rnd_buffer_size        = 32M

# �������������Ļ�������С�����������Եõ����õ������������ܣ������ڴ���4GB���ҵķ�������˵���ò���������Ϊ256MB��384MB��
# the size of the buffer used for MyISAM index blocks,shared by all threads.
# Ĭ��ֵ 8M; ��Χ 8-4294967295;

key_buffer_size             = 4G

# MyISAM�����仯ʱ������������Ļ���
# when sorting MyISAM indexes 
# Ĭ��ֵ 8m; ��Χ 4-18446744073709547520

myisam_sort_buffer_size     = 2G

# MySQL�ؽ�����ʱ������������ʱ�ļ��Ĵ�С (�� REPAIR, ALTER TABLE ���� LOAD DATA INFILE).
# ����ļ���С�ȴ�ֵ����,������ͨ����ֵ���崴��(����)
# while re-creating a MyISAM index 
# Ĭ��ֵ 2G;

myisam_max_sort_file_size   = 100G

# ���һ����ӵ�г���һ������, MyISAM ����ͨ����������ʹ�ó���һ���߳�ȥ�޸�����.
# �����ӵ�ж��CPU�Լ������ڴ�������û�,��һ���ܺõ�ѡ��.
# Note:it is still beta-quality code. If greater than 1,indexes are created in parallel.
# Ĭ��ֵ 1; ��Χ 1-18446744073709547520 

myisam_repair_threads       = 1

# myisam_recover_options

# ====================== INNODB Specific options ======================

innodb_data_home_dir           = /data/mysql/data/

# Valid Values 0,1,2.means slow shutdown,fast shutdown,flush logs and then abort respectively
# Ĭ��ֵ 1;

innodb_fast_shutdown            = 1

# innodb_force_recovery

innodb_force_recovery           = 0

# ���Innodb����˵�ǳ���Ҫ��Innodb���MyISAM��Ի����Ϊ���С�
# MyISAM������Ĭ�ϵ� key_buffer_size ���������еĿ��ԣ�Ȼ��Innodb��Ĭ�ϵ� innodb_buffer_pool_size ������ȴ����ţ�Ƶġ�
# ����Innodb�����ݺ�����������������������������ϵͳ̫����ڴ棬������ֻ��Ҫ��Innodb�Ļ�������������ߴ� 70-80% �Ŀ����ڴ档
# һЩӦ���� key_buffer �Ĺ����� �� ���������������󣬲��Ҳ��ᱩ������ô����� innodb_buffer_pool_size ���õ�̫����
# The size of the memory buffer InnoDB uses to cache data and indexes of its tables. 
# Ĭ��ֵ 128m; ��Χ 1048576-2**64-1;

innodb_buffer_pool_size         = 18000M

# �˲���ȷ��Щ��־�ļ����õ��ڴ��С����MΪ��λ��������������������ܣ�������Ĺ��Ͻ��ᶪʧ����.MySQL������Ա��������Ϊ1��8M֮��
# The size of the buffer that InnoDB uses to write to the log files on disk. 
# Ĭ��ֵ 8388608; ��Χ 262144-4294967295;

innodb_log_buffer_size          = 64M

# �˲���ȷ��������־�ļ��Ĵ�С����MΪ��λ����������ÿ���������ܣ���Ҳ�����ӻָ��������ݿ������ʱ��
# The size in bytes of each log file in a log group.
# Ĭ��ֵ 5242880; ��Χ 108576-4294967295;

#innodb_log_file_size            = 512M

# Ϊ������ܣ�MySQL������ѭ����ʽ����־�ļ�д������ļ����Ƽ�����Ϊ3M
# Ĭ��ֵ 2; ��Χ 2-100;The size in bytes of each log file in a log group.

innodb_log_files_in_group       = 2

# ��ռ��ļ� ��Ҫ����
# default behavior is to create a single 10MB auto-extending data file named ibdata1;The paths to individual data files and their sizes.;innodb_data_file_path=datafile_spec1[;datafile_spec2]...;datafile_spec=file_name:file_size[:autoextend[:max:max_file_size]]

innodb_data_file_path           = ibdata1:100M:autoextend

# Valid Values Antelope Barracuda;The file format to use for new per-table tablespace InnoDB tables.
# Default Antelope;

innodb_file_format              = Antelope

# �����ռ䣨����
# If disabled (the default),tables created in the system tablespace.If enabled,each new table create its own .ibd file.

innodb_file_per_table           = 1


# The number of I/O threads for write operations in InnoDB.
# Ĭ��ֵ 4; ��Χ 1-64;

innodb_write_io_threads         = 8

# The number of I/O threads for read operations in InnoDB.
# Ĭ��ֵ 4; ��Χ 1-64;

innodb_read_io_threads          = 8

# 20000

innodb_io_capacity              = 200

# specifies the maximum number of .ibd files that MySQL can keep open at one time. 
# independent from --open-files-limit and table cache.
# Default 300;Range 10-4294967295;

innodb_open_files               = 1024

# InnoDB�е����������һ�ඨ�ڻ����������ݵĲ�������֮ǰ�ļ����汾�У�������������̵߳�һ���֣�����ζ������ʱ�����ܻ�������������ݿ������
# ��MySQL5.5.X�汾��ʼ���ò��������ڶ������߳���,��֧�ָ���Ĳ��������û���ͨ������innodb_purge_threads���ò�����ѡ����������Ƿ�ʹ�õ�
# ���߳�,Ĭ������²�������Ϊ0(��ʹ�õ����߳�),����Ϊ 1 ʱ��ʾʹ�õ���������̡߳�����Ϊ1
# set 1 can reduce internal contention within InnoDB, improving scalability.but now the performance gain might be minimal.
# Default 0;

innodb_purge_threads            = 1

# �������м���CPU������Ϊ����������Ĭ�����ã�һ��Ϊ8.
# InnoDB tries to keep threads concurrently inside InnoDB less than this limit. 
# Ĭ��ֵ 0; ��Χ 0-1000;

innodb_thread_concurrency       = 0

# ������˲�������Ϊ1������ÿ���ύ�������־д����̡�Ϊ�ṩ���ܣ���������Ϊ0��2����Ҫ�е��ڷ�������ʱ��ʧ���ݵķ��ա�
# ����Ϊ0��ʾ������־д����־�ļ�������־�ļ�ÿ��ˢ�µ�����һ�Ρ�����Ϊ2��ʾ������־�����ύʱд����־������־�ļ�ÿ��ˢ�µ�����һ�Ρ�
# Valid Values 0,1,2; you should read manual for details
# Ĭ��ֵ 1;

innodb_flush_log_at_trx_commit  = 2

# Default fdatasync; Valid Values O_DSYNC,O_DIRECT; specify the way to open and flush files.

innodb_flush_method             = O_DIRECT

# Buffer_Pool��Dirty_Page��ռ��������ֱ��Ӱ��InnoDB�Ĺر�ʱ�䡣
# ����innodb_max_dirty_pages_pct ����ֱ�ӿ�����Dirty_Page��Buffer_Pool����ռ�ı��ʣ�
# �������˵���innodb_max_dirty_pages_pct�ǿ��Զ�̬�ı�ġ����ԣ��ڹر�InnoDB֮ǰ�Ƚ�innodb_max_dirty_pages_pct��С��
# ǿ�����ݿ�Flushһ��ʱ�䣬���ܹ�������� MySQL�رյ�ʱ�䡣

innodb_max_dirty_pages_pct      = 90

# InnoDB �������õ����������ƣ��ܵ���δ��ɵ�����ع������ǣ�������InnoDBʹ��MyISAM��lock tables �����������������,
# ��InnoDB�޷�ʶ��������Ϊ�������ֿ����ԣ����Խ�innodb_lock_wait_timeout����Ϊһ������ֵ��
# ָʾ MySQL���������������޸���Щ����������ع�������֮ǰҪ�ȴ��೤ʱ��(����)
# The timeout in seconds an InnoDB transaction waits for a row lock before giving up.
# Ĭ��ֵ 50; ��Χ 1-1073741824;

innodb_lock_wait_timeout        = 1000

# ��������������� InnoDB �洢������Ŀ¼��Ϣ�������ڲ����ݽṹ���ڴ�ش�С��Ӧ�ó�����ı�Խ�࣬����Ҫ���������Խ����ڴ档
# ����һ������ȶ���Ӧ�ã���������Ĵ�СҲ����� �ȶ��ģ�Ҳû�б�ҪԤ���ǳ����ֵ����� InnoDB �ù���������ڵ��ڴ棬 
# InnoDB ��ʼ�Ӳ���ϵͳ�����ڴ棬������ MySQL ������־д������Ϣ��Ĭ��ֵ�� 1MB �������ִ�����־���Ѿ�����صľ�����Ϣʱ��
# ��Ӧ���ʵ������Ӹò����Ĵ�С��
# The size of a memory pool InnoDB uses to store data dictionary information and other internal data structures.
# Default 8388608;Range 2097152-4294967295;

#innodb_additional_mem_pool_size = 67108864

# ��������innodb�ϸ�ģʽ�����ϸ�ģʽ��innodb��һЩ�����»�ֱ�ӱ��������Ƿ���������߱��ش���ĳЩ�﷨

innodb_strict_mode                = 1

# ����InnoDB�ϸ���ģʽ�������ǲ�����ҳ����ѹ������ʱ������ǿ����ù��ܡ�
# ����﷨�д��󣬲����о�����Ϣ������ֱ���׳����󣬺ô���ֱ�ӽ������ɱ��ҡ���Ĭ���ǹرա�

innodb_use_native_aio             = 1

innodb_buffer_pool_instances      = 8

# innodb_status_file              = 1

innodb_stats_on_metadata

# ================================ Log ================================

# Log errors and startup messages to this file.
# Ĭ��ֵ host_name.err;

log-error                       = /var/log/mysql/error.log

# Whether to produce additional warning messages to the error log. 
# Ĭ��ֵ 1; ��Χ 0, 1, greater than 1;

#log-warnings

# Disable log-warnings

#skip-log-warnings

# Specify the initial general query log state.
# Ĭ��ֵ OFF;

#general-log                     = 1

# The name of the general query log file.
# Ĭ��ֵ host_name.log;

#general_log_file                = /home/mysql/logs/general.log

# Whether the slow query log is enabled
# Ĭ��ֵ OFF;

#slow-query-log

# The name of the slow query log file.
# Ĭ��ֵ host_name-slow.log;

#slow_query_log_file             = /home/mysql/logs/slow.log

# query longer than long_query_time seconds will be log to slow log and slow_queries status variable.
# Ĭ��ֵ 10;

long_query_time                 = 60

# queries that are expected to retrieve all rows are logged.
# Ĭ��ֵ OFF;

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
