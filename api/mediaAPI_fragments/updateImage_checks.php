<?php
if(!defined('validator'))
    require __DIR__ . '/../../IOFrame/Util/validator.php';

//Address
if($inputs['address'] !== null){

    $valid = \IOFrame\Util\validator::validateRelativeFilePath($inputs['address']);
    $valid = $valid || filter_var($inputs['address'],FILTER_VALIDATE_URL);

    if(!$valid){
        if($test)
            echo 'Invalid address!'.EOL;
        exit(INPUT_VALIDATION_FAILURE);
    }

    $inputs['addresses'] = [$inputs['address']];
}
else{
    if($test)
        echo 'Address must be set!'.EOL;
    exit(INPUT_VALIDATION_FAILURE);
}

//Alt and Name
$meta = [];

if(!$inputs['deleteEmpty'] && $inputs['alt'] === null && $inputs['name'] === null && $inputs['caption'] === null ){
    if($test)
        echo 'Either alt, caption or name have to be set!'.EOL;
    exit(INPUT_VALIDATION_FAILURE);
}

if($inputs['alt'] !== null){

    if(strlen($inputs['alt'])>IMAGE_ALT_MAX_LENGTH){
        if($test)
            echo 'Maximum alt length: '.IMAGE_ALT_MAX_LENGTH.EOL;
        exit(INPUT_VALIDATION_FAILURE);
    }

    $meta['alt'] = $inputs['alt'];
}

if($inputs['name'] !== null){

    if(strlen($inputs['name'])>IMAGE_NAME_MAX_LENGTH){
        if($test)
            echo 'Maximum name length: '.IMAGE_NAME_MAX_LENGTH.EOL;
        exit(INPUT_VALIDATION_FAILURE);
    }

    $meta['name'] = $inputs['name'];
}


if($inputs['caption'] !== null){

    if(strlen($inputs['caption'])>IMAGE_CAPTION_MAX_LENGTH){
        if($test)
            echo 'Maximum caption length: '.IMAGE_CAPTION_MAX_LENGTH.EOL;
        exit(INPUT_VALIDATION_FAILURE);
    }

    $meta['caption'] = $inputs['caption'];
}

if($inputs['deleteEmpty']){

    if($inputs['alt'] === null){
        $meta['alt'] = null;
    };

    if($inputs['name'] === null){
        $meta['name'] = null;
    };

    if($inputs['caption'] === null){
        $meta['caption'] = null;
    };
}

$meta = json_encode($meta);
