<?php

if($inputs['tokens'] !== null){
    if(!\IOFrame\Util\is_json($inputs['tokens'])){
        if($test)
            echo 'tokens must be a valid JSON!'.EOL;
        exit(INPUT_VALIDATION_FAILURE);
    }
    $inputs['tokens'] = json_decode($inputs['tokens'],true);

    foreach($inputs['tokens'] as $token => $tokenArr){

        if(!preg_match('/'.TOKEN_REGEX.'/',$token)){
            if($test)
                echo 'Every token needs to match regex '.TOKEN_REGEX.EOL;
            exit(INPUT_VALIDATION_FAILURE);
        }

        if(!isset($tokenArr['action']) || !isset($tokenArr['ttl'])){
            if($test)
                echo 'Every token needs to have action and ttl set!'.EOL;
            exit(INPUT_VALIDATION_FAILURE);
        }

        if(!preg_match('/'.ACTION_REGEX.'/',$tokenArr['action'])){
            if($test)
                echo 'Every token action needs to match regex '.ACTION_REGEX.EOL;
            exit(INPUT_VALIDATION_FAILURE);
        }

        if(!filter_var($tokenArr['ttl'],FILTER_VALIDATE_INT)){
            if($test)
                echo 'ttl needs to be a positive int!'.EOL;
            exit(INPUT_VALIDATION_FAILURE);
        }

        if( isset($tokenArr['uses']) && !($tokenArr['uses'] === 0 || filter_var($tokenArr['uses'],FILTER_VALIDATE_INT)) ){
            if($test)
                echo 'uses needs to be an int!'.EOL;
            exit(INPUT_VALIDATION_FAILURE);
        }

    }
}
else{
    if($test)
        echo 'tokens must be set!'.EOL;
    exit(INPUT_VALIDATION_FAILURE);
}
