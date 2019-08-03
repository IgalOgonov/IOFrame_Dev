<?php

require __DIR__.'/../../IOFrame/Handlers/SecurityHandler.php';
$SecurityHandler = new \IOFrame\Handlers\SecurityHandler($settings,$defaultSettingsParams);

echo EOL.'Commiting event 0 by this IP:'.EOL;
var_dump($SecurityHandler->commitEventIP(0,['test'=>true]));