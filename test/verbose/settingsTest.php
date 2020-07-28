<?php

echo 'Setting new site setting randomSetting to value 3600:'.EOL;
var_dump(
    $siteSettings->setSetting('tokenTTL',3600,['createNew'=>true,'test'=>true,'verbose'=>true])
);
echo EOL;

echo 'Unsetting sitesetting tokenTTL'.EOL;
var_dump(
    $siteSettings->setSetting('tokenTTL',null,['test'=>true,'verbose'=>true])
);
echo EOL;

echo 'Syncing local settings with DB (should fail):'.EOL;
var_dump(
    $settings->syncWithDB(['test'=>true,'verbose'=>true])
);
echo EOL;

$combined = new IOFrame\Handlers\SettingsHandler(
    [$rootFolder.'/localFiles/resourceSettings/',$rootFolder.'/localFiles/mailSettings/',$rootFolder.'/localFiles/userSettings/']
    ,$defaultSettingsParams
);
$noMailSettings = clone $combined;
$noMailSettings->keepSettings(['resourceSettings','userSettings']);
echo 'Printing settings that were created from fetching 3 setting sets and keeping 2:'.EOL;
$noMailSettings ->printAll();
echo EOL;

$mailSettings = new IOFrame\Handlers\SettingsHandler($rootFolder.'/localFiles/mailSettings/',$defaultSettingsParams);

echo 'Initiating mail settings DB table:'.EOL;
var_dump(
    $mailSettings->initDB(['test'=>true])
);
echo EOL;

echo 'Syncing mail settings with DB (should succeed):'.EOL;
var_dump(
    $mailSettings->syncWithDB(['localToDB'=>false,'test'=>true,'verbose'=>true])
);
echo EOL;