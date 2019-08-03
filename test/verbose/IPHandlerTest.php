<?php


require_once __DIR__.'/../../IOFrame/Handlers/IPHandler.php';

if(!isset($IPHandler))
$IPHandler = new IOFrame\Handlers\IPHandler(
    $settings,
    array_merge($defaultSettingsParams, ['siteSettings'=>$siteSettings])
);

echo '10.213.234.10 blacklisted? '.$IPHandler->checkIP(['ip'=>'10.213.234.10','checkRange'=>true,'blacklisted'=>true,'test'=>true]).EOL;
echo '10.213.234.10 whitelisted? '.$IPHandler->checkIP(['ip'=>'10.213.234.10','checkRange'=>true,'blacklisted'=>false,'test'=>true]).EOL;
echo '10.10.21.50 blacklisted? '.$IPHandler->checkIP(['ip'=>'10.10.21.50','checkRange'=>true,'blacklisted'=>true,'test'=>true]).EOL;
echo '10.10.21.50 whitelisted? '.$IPHandler->checkIP(['ip'=>'10.10.21.50','checkRange'=>true,'blacklisted'=>false,'test'=>true]).EOL;
echo '10.213.234.0 whitelisted? '.$IPHandler->checkIP(['ip'=>'10.213.234.0','checkRange'=>true,'blacklisted'=>false,'test'=>true]).EOL;
echo '10.0.0.0 whitelisted? '.$IPHandler->checkIP(['ip'=>'10.0.0.0','checkRange'=>true,'blacklisted'=>false,'test'=>true]).EOL;

echo 'Adding IP 10.213.234.0 to whitelist:'.EOL;
echo $IPHandler->addIP('10.213.234.0',true,['ttl'=>600000,'reliable'=>false,'override'=>true,'test'=>true]).EOL;

echo 'Reducing IP 10.213.234.0 TTL to 3000:'.EOL;
echo $IPHandler->updateIP('10.213.234.0',true,['ttl'=>3000,'reliable'=>true,'test'=>true]).EOL;

echo 'Deleting IP 10.213.234.0:'.EOL;
echo $IPHandler->deleteIP('10.213.234.0',['test'=>true]).EOL;

echo 'Adding IP range to whitelist - 10.10.0-21'.EOL;
echo $IPHandler->addIPRange('10.10',0,21,true,3000,['override'=>true,'test'=>true]).EOL;

echo 'Updating range 10.10.0-21 to be blacklisted, from range 10 to 25'.EOL;
echo $IPHandler->updateIPRange('10.10',0,21,['type'=>false,'from'=>10,'to'=>25,'test'=>true]).EOL;

echo 'Deleting range 10.10.0-21'.EOL;
echo $IPHandler->deleteIPRange('10.10',0,21,['test'=>true]).EOL;

echo 'Deleting expired rules'.EOL;
echo $IPHandler->deleteExpired(['test'=>true,'range'=>true]).EOL;

