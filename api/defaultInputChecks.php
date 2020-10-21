<?php

//This always indicates test mode
$test = ( isset($_REQUEST['req']) && $_REQUEST['req'] == 'test' ) &&
    ( $siteSettings->getSetting('allowTesting') || $auth->isAuthorized(0) || !empty($_SESSION['allowTesting']) );

//Fix any values that are strings due to softly typed language bullshit
foreach($_REQUEST as $key=>$value){
    if($_REQUEST[$key] === '')
        unset($_REQUEST[$key]);
    else if($_REQUEST[$key] === 'false')
        $_REQUEST[$key] = false;
    else if($_REQUEST[$key] === 'true')
        $_REQUEST[$key] = true;
    else if(preg_match('/\D/',$_REQUEST[$key]) == 0)
        $_REQUEST[$key] = (int)$_REQUEST[$key];
}





