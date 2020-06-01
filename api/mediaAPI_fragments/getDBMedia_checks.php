<?php
if(!defined('validator'))
    require __DIR__ . '/../../IOFrame/Util/validator.php';

//Check to see if the API is even enabled
if(!$resourceSettings->getSetting('allowDBMediaGet')){
    header("HTTP/1.1 403 API Disabled");
    die();
}

if($inputs['address'] !== null){
    if(!\IOFrame\Util\validator::validateRelativeDirectoryPath($inputs['address'])){
        header("HTTP/1.1 400 Invalid address");
        die();
    }
}
else{
    header("HTTP/1.1 400 Invalid address");
    die();
}

if($inputs['resourceType'] !== null){
    //TODO Check individual image auth
    if(!preg_match('/'.RESOURCE_TYPE_REGEX.'/',$inputs['resourceType'])){
        header("HTTP/1.1 400 Invalid resource type");
        die();
    }
}
else
    $inputs['resourceType'] = 'img';

if($inputs['lastChanged'] !== null){
    //TODO Check individual image auth
    if(!filter_var($inputs['lastChanged'],FILTER_VALIDATE_INT)){
        $inputs['lastChanged'] = null;
    }
}

//TODO Check individual resource auth