<?php

function validateCSRFToken(){
    return ( isset($_REQUEST['CSRF_token']) && $_REQUEST['CSRF_token'] === $_SESSION['CSRF_token'] ) ||
    (!empty($_SESSION['CSRF_validated']) && $_SESSION['CSRF_validated'] > time());
}

function validateThenRefreshCSRFToken($SessionHandler){
    $res = validateCSRFToken();
    if($res){
        //Prolong CSRF_validated but reset the token
        $_SESSION['CSRF_validated'] = time() + 10;
        $SessionHandler->reset_CSRF_token();
    }
    return $res;
}

