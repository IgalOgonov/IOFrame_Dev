<?php
$apiSettings = new IOFrame\Handlers\SettingsHandler($rootFolder.'/localFiles/apiSettings/',$defaultSettingsParams);
function checkApiEnabled($name,$apiSettings,$specificAction = null,$params = []){
    $checkAction = (isset($params['checkAction'])? $params['checkAction'] : true) && $specificAction;
    $relevantSetting = $apiSettings->getSetting($name);
    $validSettings = \IOFrame\Util\is_json($relevantSetting);
    if(!$validSettings)
        return true;
    else
        $relevantSetting = json_decode($relevantSetting,true);
    //Check the API is active, and (if we're checking provided a specific action!) the action is allowed
    return (!isset($relevantSetting['active']) || $relevantSetting['active']) &&
        (!$checkAction || !isset($relevantSetting[$specificAction]) || $relevantSetting[$specificAction] );
}