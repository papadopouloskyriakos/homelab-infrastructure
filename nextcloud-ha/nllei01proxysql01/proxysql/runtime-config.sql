-- ProxySQL runtime configuration snapshot — nlproxysql01 (10.0.X.X)
-- Generated 2026-08-28T13:11:58Z from the admin interface on :6032.
--
-- SNAPSHOT ONLY. Nothing applies this automatically — there is no deploy pipeline
-- for ProxySQL, and its live config lives in SQLite (/srv/proxysql/proxysql_data/
-- proxysql.db), NOT in the mounted proxysql.cnf (which is read only on first init).
-- To restore: paste into the :6032 admin interface, then run the LOAD/SAVE at the end.
-- Both proxysql nodes must be kept identical.

-- ============ mysql_galera_hostgroups ============
-- max_writers=1 is LOAD-BEARING: set 2026-08-01 to stop multi-writer certification
-- conflicts (NCHA), and since 2026-08-28 also required for data integrity because
-- CiviCRM forced wsrep_auto_increment_control=OFF on both Galera nodes.
INSERT INTO mysql_galera_hostgroups (writer_hostgroup,backup_writer_hostgroup,reader_hostgroup,offline_hostgroup,active,max_writers,writer_is_also_reader,max_transactions_behind) VALUES (10,30,20,40,1,1,1,0);

-- ============ mysql_servers ============
INSERT INTO mysql_servers (hostgroup_id,hostname,port,weight,max_connections) VALUES (10,'10.0.X.X',3306,100,1000);
INSERT INTO mysql_servers (hostgroup_id,hostname,port,weight,max_connections) VALUES (10,'10.0.X.X',3306,100,1000);
INSERT INTO mysql_servers (hostgroup_id,hostname,port,weight,max_connections) VALUES (20,'10.0.X.X',3306,100,1000);
INSERT INTO mysql_servers (hostgroup_id,hostname,port,weight,max_connections) VALUES (20,'10.0.X.X',3306,100,1000);
INSERT INTO mysql_servers (hostgroup_id,hostname,port,weight,max_connections) VALUES (30,'10.0.X.X',3306,100,1000);
-- NOTE: 'status' deliberately omitted — .150 shows SHUNNED in HG10 as ProxySQL's
-- intentional max_writers=1 demotion, not a fault. Let ProxySQL re-derive it.

-- ============ mysql_query_rules ============
-- rule_id 0 is LOAD-BEARING for CiviCRM: rules 1-3 are global (username NULL) and
-- send every ^SELECT to reader HG20; CiviCRM's temp tables are writer-session-local.
INSERT INTO mysql_query_rules (rule_id,active,username,match_digest,destination_hostgroup,apply) VALUES (0,1,'civicrm','.*',10,1);
INSERT INTO mysql_query_rules (rule_id,active,username,match_digest,destination_hostgroup,apply) VALUES (1,1,NULL,'^INSERT|^UPDATE|^DELETE|^REPLACE|^BEGIN',10,1);
INSERT INTO mysql_query_rules (rule_id,active,username,match_digest,destination_hostgroup,apply) VALUES (2,1,NULL,'^SELECT',20,1);
INSERT INTO mysql_query_rules (rule_id,active,username,match_digest,destination_hostgroup,apply) VALUES (3,1,NULL,'.*',10,1);

-- ============ mysql_users ============
INSERT INTO mysql_users (username,password,default_hostgroup,active,transaction_persistent,max_connections) VALUES ('civicrm','REDACTED_67ad0fc1',10,1,1,1000);
INSERT INTO mysql_users (username,password,default_hostgroup,active,transaction_persistent,max_connections) VALUES ('cluster_admin','cluster_password',0,1,1,10000);
INSERT INTO mysql_users (username,password,default_hostgroup,active,transaction_persistent,max_connections) VALUES ('finops','REDACTED_8c83f800',10,1,1,10000);
INSERT INTO mysql_users (username,password,default_hostgroup,active,transaction_persistent,max_connections) VALUES ('finops_agora','REDACTED_d1d1e94d',10,1,1,10000);
INSERT INTO mysql_users (username,password,default_hostgroup,active,transaction_persistent,max_connections) VALUES ('grafana_ro','REDACTED_2bc77bc4',20,1,1,10);
INSERT INTO mysql_users (username,password,default_hostgroup,active,transaction_persistent,max_connections) VALUES ('healthops','REDACTED_1bac42ef',10,1,1,10000);
INSERT INTO mysql_users (username,password,default_hostgroup,active,transaction_persistent,max_connections) VALUES ('monitor','REDACTED_3585623d',1,1,1,10000);
INSERT INTO mysql_users (username,password,default_hostgroup,active,transaction_persistent,max_connections) VALUES ('n8n_finops','REDACTED_8f6b408a',10,1,1,10000);
INSERT INTO mysql_users (username,password,default_hostgroup,active,transaction_persistent,max_connections) VALUES ('nextcloud','REDACTED_4c3eafd9',0,1,1,10000);
INSERT INTO mysql_users (username,password,default_hostgroup,active,transaction_persistent,max_connections) VALUES ('paperless','49433ffe662e7a8923fdfead6d6b2fee',10,1,1,10000);

LOAD MYSQL SERVERS TO RUNTIME;      SAVE MYSQL SERVERS TO DISK;
LOAD MYSQL USERS TO RUNTIME;        SAVE MYSQL USERS TO DISK;
LOAD MYSQL QUERY RULES TO RUNTIME;  SAVE MYSQL QUERY RULES TO DISK;
