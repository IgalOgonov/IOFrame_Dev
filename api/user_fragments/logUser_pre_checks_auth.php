<?php

if(!defined('IPHandler'))
    require __DIR__ . '/../../IOFrame/Handlers/IPHandler.php';


//We need to check whether the current IP is blacklisted
if(!isset($IPHandler))
    $IPHandler = new \IOFrame\Handlers\IPHandler(
        $settings,
        array_merge($defaultSettingsParams,['siteSettings'=>$siteSettings])
    );

//IP check
if($IPHandler->checkIP(['test'=>$test]))
    exit(SECURITY_FAILURE);

if(!isset($userSettings))
    $userSettings = new IOFrame\Handlers\SettingsHandler(
        $settings->getSetting('absPathToRoot').'/'.SETTINGS_DIR_FROM_ROOT.'/userSettings/',
        $defaultSettingsParams
    );


//If regular login is not allowed, return 4 (login type not allowed).
if($userSettings->getSetting('allowRegularLogin') != 1){
    if($test)
        echo 'Logging through this API is not allowed!'.EOL;
    exit(AUTHENTICATION_FAILURE);
}


if( $inputs["userID"]!=null && $userSettings->getSetting('rememberMe') < 1){
    if($test)
        echo 'Cannot log in automatically when rememberMe server setting is less then 1! Don\'t post userID!'.EOL;
    exit(AUTHENTICATION_FAILURE);
}
