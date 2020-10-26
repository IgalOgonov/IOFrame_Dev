<?php
if(!defined('actionDefaults'))
    define('actionDefaults',true);
if(!isset($baseUrl))
    $baseUrl = $settings->getSetting('absPathToRoot');
if(!defined("EOL"))
    define("EOL",PHP_EOL);
if(!isset($timingManager))
    $timingManager = new IOFrame\Util\timingManager();
if(!isset($redisSettings))
    $redisSettings = new IOFrame\Handlers\SettingsHandler($baseUrl.'localFiles/redisSettings/',['useCache'=>false]);
if(!isset($RedisHandler))
    $RedisHandler = new IOFrame\Handlers\RedisHandler($redisSettings);
if(!isset($defaultSettingsParams)){
    $defaultSettingsParams = [];
    if($RedisHandler->isInit){
        $defaultSettingsParams['useCache'] = true;
    }
    $defaultSettingsParams['RedisHandler'] = $RedisHandler;
    $SQLHandler = new IOFrame\Handlers\SQLHandler(
        $settings,
        $defaultSettingsParams
    );
    $defaultSettingsParams['SQLHandler'] = $SQLHandler;
}