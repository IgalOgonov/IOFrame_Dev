<?php
$retrieveParams = [
    'test'=>$test
];

$requiredAuth = REQUIRED_AUTH_NONE;

//Handle id
if($inputs['id'] !== null){
    if(!filter_var($inputs['id'],FILTER_VALIDATE_INT)){
        if($test)
            echo 'id must be a valid integer!'.EOL;
        exit(INPUT_VALIDATION_FAILURE);
    }
}
else{
    if($inputs['articleAddress'] !== null){
        if(strlen($inputs['articleAddress']) > ADDRESS_MAX_LENGTH){
            if($test)
                echo 'Each articleAddress must be at most '.ADDRESS_MAX_LENGTH.' characters long!'.EOL;
            exit(INPUT_VALIDATION_FAILURE);
        }
        $address = explode('-', $inputs['articleAddress']);
        foreach( $address as $subValue)
            if(!preg_match('/'.ADDRESS_SUB_VALUE_REGEX.'/',$subValue)){
                if($test)
                    echo 'Each value in articleAddress must be a sequence of low-case characters
                                and numbers separated by "-", each sequence no longer than 24 characters long'.EOL;
                exit(INPUT_VALIDATION_FAILURE);
            }
        $inputs['authAtMost'] = null;
    }
    else{
        if($test)
            echo 'id must be set!'.EOL;
        exit(INPUT_VALIDATION_FAILURE);
    }
}

//Set 'authAtMost' if not requested by the user
if($inputs['authAtMost'] !== null){
    if(!($inputs['authAtMost'] === 0 || filter_var($inputs['authAtMost'],FILTER_VALIDATE_INT))){
        if($test)
            echo 'authAtMost must be a valid integer!'.EOL;
        exit(INPUT_VALIDATION_FAILURE);
    }

    if($inputs['authAtMost'] === 0)
        $requiredAuth = 0;
    elseif($inputs['authAtMost'] === 1)
        $requiredAuth = max($requiredAuth,REQUIRED_AUTH_RESTRICTED);
    elseif($inputs['authAtMost'] == 2)
        $requiredAuth = max($requiredAuth,REQUIRED_AUTH_OWNER);
    else
        $requiredAuth = max($requiredAuth,REQUIRED_AUTH_ADMIN);
}

//Set 'ignoreOrphan' if requested by the user
if($inputs['ignoreOrphan'] !== null){
    $requiredAuth = max($requiredAuth,REQUIRED_AUTH_OWNER);
    $inputs['ignoreOrphan'] = (bool)$inputs['ignoreOrphan'];
}
else
    $inputs['ignoreOrphan'] = true;

$inputs['preloadGalleries'] = $inputs['preloadGalleries'] !== null ? $inputs['preloadGalleries'] : true;

$retrieveParams['authAtMost'] = $requiredAuth;