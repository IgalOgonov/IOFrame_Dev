<?php
if(!defined('UserHandler'))
    require __DIR__ . '/../../IOFrame/Handlers/UserHandler.php';
if(!defined('IPHandler'))
    require __DIR__ . '/../../IOFrame/Handlers/IPHandler.php';


//We need to check whether the current IP is blacklisted
$IPHandler = new \IOFrame\Handlers\IPHandler(
    $settings,
    array_merge($defaultSettingsParams,['siteSettings'=>$siteSettings])
);

if(!isset($UserHandler))
    $UserHandler = new IOFrame\Handlers\UserHandler(
        $settings,
        $defaultSettingsParams
    );

//Check if the user is eligible to log in
if($inputs["log"]!='out')
    if ($UserHandler->checkUserLogin($inputs["m"],['allowWhitelistedIP' => $IPHandler->directIP,'test'=>$test]) === 1){
        if($test)
            echo 'Suspicious user activity - cannot login without 2FA or whitelisting the IP!'.EOL;
        exit(SECURITY_FAILURE);
    }
