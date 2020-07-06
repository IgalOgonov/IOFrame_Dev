<?php

//Gallery
if($inputs['gallery'] !== null){
    if(!preg_match('/'.GALLERY_REGEX.'/',$inputs['gallery'])){
        if($test)
            echo 'Invalid gallery name!'.EOL;
        exit(INPUT_VALIDATION_FAILURE);
    }
}
else{
    if($test)
        echo 'Gallery name must be set!'.EOL;
    exit(INPUT_VALIDATION_FAILURE);
}

//Meta information
if($inputs['name']){

    if(strlen($inputs['name'])>GALLERY_NAME_MAX_LENGTH){
        if($test)
            echo 'Invalid image name for '.$inputs['gallery'].EOL;
        exit(INPUT_VALIDATION_FAILURE);
    }

    $meta = json_encode(['name'=>$inputs['name']]);

}
else
    $meta = null;









