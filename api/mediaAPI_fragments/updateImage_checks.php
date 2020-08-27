<?php
if(!defined('validator'))
    require __DIR__ . '/../../IOFrame/Util/validator.php';
require_once __DIR__ . '/../../IOFrame/Handlers/ext/htmlpurifier/HTMLPurifier.standalone.php';
$config = HTMLPurifier_Config::createDefault();
$config->set('HTML.AllowedElements', []);
$purifier = new HTMLPurifier($config);

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
$expected = ['name','alt','caption'];
foreach($languages as $lang){
    array_push($expected,$lang.'_name');
    array_push($expected,$lang.'_caption');
}
$anythingSet = false;
foreach($expected as $attr)
    if($inputs[$attr] !== null){
        $anythingSet = true;
        $inputs[$attr] = $purifier->purify($inputs[$attr]);
    }

if(!$inputs['deleteEmpty'] && !$anythingSet ){
    if($test)
        echo 'With deleteEmpty, at least one meta attribute needs to be set!'.EOL;
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

$nameArr = ['name'];
foreach($languages as $lang){
    array_push($nameArr,$lang.'_name');
}
foreach($nameArr as $nameParam)
    if($inputs[$nameParam] !== null){
        if(strlen($inputs[$nameParam])>IMAGE_NAME_MAX_LENGTH){
            if($test)
                echo 'Maximum name length: '.IMAGE_NAME_MAX_LENGTH.EOL;
            exit(INPUT_VALIDATION_FAILURE);
        }
    }


$captionArr = ['caption'];
foreach($languages as $lang){
    array_push($captionArr,$lang.'_caption');
}
foreach($captionArr as $captionParam)
    if($inputs[$captionParam] !== null){
        if(strlen($inputs[$captionParam])>IMAGE_CAPTION_MAX_LENGTH){
            if($test)
                echo 'Maximum caption length: '.IMAGE_CAPTION_MAX_LENGTH.EOL;
            exit(INPUT_VALIDATION_FAILURE);
        }
    }

if($inputs['deleteEmpty']){
    foreach($expected as $attr)
        if($inputs[$attr] === null){
            $meta[$attr] = null;
        };
}


$meta = json_encode($meta);
