<?php
$CONFIG = array (
'filelocking.enabled' => true,
'memcache.local' => '\OC\Memcache\APCu',
'memcache.distributed' => '\OC\Memcache\Redis',
'memcache.locking' => '\OC\Memcache\Redis',
'redis' => [
    'host' => 'redis.example.net',
    'port' => '6380',
    'dbindex' => 0,
    'timeout' => 5.0,
    'read_timeout' => 5.0,
],
);
