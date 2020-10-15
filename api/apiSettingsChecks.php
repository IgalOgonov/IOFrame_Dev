<?php
$apiSettings = new IOFrame\Handlers\SettingsHandler($rootFolder.'/localFiles/apiSettings/',$defaultSettingsParams);
function checkApiEnabled($name,$apiSettings){
    return $apiSettings->getSetting($name) === null || $apiSettings->getSetting($name);
}
