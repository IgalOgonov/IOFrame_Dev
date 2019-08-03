<?php

if(!defined('validator'))
    require __DIR__ . '/../../IOFrame/Util/validator.php';

if($params == null){
    if($test)
        echo 'Params must be set!';
    exit(INPUT_VALIDATION_FAILURE);
}


if($action == 'modifyUserActions' || $action == 'modifyUserGroups' )
    $expectedTarget = 'id';
else
    $expectedTarget = 'groupName';

if(!isset($params[$expectedTarget])){
    if($test)
        echo $expectedTarget.' must be an set!'.EOL;
    exit(INPUT_VALIDATION_FAILURE);
}

if($expectedTarget == 'id'){
    if(!filter_var($params[$expectedTarget],FILTER_VALIDATE_INT)){
        if($test)
            echo 'ID must be a number!'.EOL;
        exit(INPUT_VALIDATION_FAILURE);
    }
}
else{
    if(!\IOFrame\Util\validator::validateSQLKey($params[$expectedTarget])){
        if($test)
            echo 'Group must be a string of 1 to 256 characters!'.EOL;
        exit(INPUT_VALIDATION_FAILURE);
    }
}


if($action == 'modifyUserActions' || $action == 'modifyGroupActions' )
    $expectedParam = 'actions';
else
    $expectedParam = 'groups';

if(!isset($params[$expectedParam]) || !is_array($params[$expectedParam])){
    if($test)
        echo $expectedParam.' must be an associative array!'.EOL;
    exit(INPUT_VALIDATION_FAILURE);
}

foreach($params[$expectedParam] as $name => $assignment){
    //Potentially correct the assignment
    if($assignment == '0' || strtolower($assignment) == 'false')
        $params[$expectedParam][$name] = false;

    if(!\IOFrame\Util\validator::validateSQLKey($name)){
        if($test)
            echo 'Each member of '.$expectedParam.' must be a string of 1 to 256 characters!'.EOL;
        exit(INPUT_VALIDATION_FAILURE);
    }
}

//Auth check TODO Add relevant actions, not just rank 0
//TODO REMEMBER DIFFERENT ACTIONS - DEPENDING ON REQUEST

if(!$auth->isAuthorized(0)){
    if($test)
        echo 'Authorization rank must be 0!';
    exit(AUTHENTICATION_FAILURE);
}



