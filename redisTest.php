
<?php
session_start();

if(class_exists('Redis'))
    echo 'Redis exists;<br>';
else
    die('Redis does not exist!');
try{
    $redis = new Redis();
    $redis->connect('127.0.0.1', 6379,5);
}
catch(\Exception $e){
    echo 'Redis connection error:'.$e;
    die();
}
//$redis->set('_auth_userLastUpdated_1','0');
//$redis->set('_auth_userActions_1','["ASSIGN_OBJECT_AUTH","REMOVED_ACTION"]');
//$redis->set('_auth_userGroups_1','["Test Group","Removed Group"]');
//$redis->set('_auth_groupLastUpdated_Test Group','0');
//$redis->set('_auth_groupActions_Test Group','["TREE_R_AUTH"]');
//$redis->set('Test Value','{"Nice!":"Nice!"}');
//$redis->set('Test Value','{"Nice!":"Nice!"}');
//$redis->set('Test Value','{"Nice!":"Nice!"}');
//$redis->del('ioframe_object_group_courses');
//$redis->set('_settings_sqlSettings','{"sql_table_prefix":"","sql_server_addr":"127.0.0.1","sql_server_port":"3307","sql_username":"shiftDBCon","sql_password":"SPHHRE5M2SZjk2KK","sql_db_name":"iframe_dev"}');
$redis->setOption(Redis::OPT_SERIALIZER, Redis::SERIALIZER_NONE);
$allKeys = $redis->keys('*');

echo '<b>Current session:</b> '.session_id().'<br>';

$indexMap = [];
foreach($allKeys as $index=>$key){
    $indexMap[$index] = $key;
}

$mGet = $redis->mGet($allKeys);

foreach($mGet as $index=>$val){
    echo '<b>'.$indexMap[$index].'</b> | '.$val.' | '.$redis->ttl($indexMap[$index]).'<br>';
    //$val = $redis->del($key);
}
?>