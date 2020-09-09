<?php
if(!defined('ResourceHandler'))
    require __DIR__ . '/../../IOFrame/Handlers/ResourceHandler.php';

$ResourceHandler = new IOFrame\Handlers\ResourceHandler($settings,$defaultSettingsParams);


$img = $ResourceHandler->getResources(
    [$inputs['address']],
    $inputs['resourceType'],
    ['test'=>false,'verbose'=>false,'ignoreBlob'=>false]
);

if(
    isset($img[$inputs['address']]) &&
    is_array($img[$inputs['address']]) &&
    $img[$inputs['address']]["Data_Type"] &&
    $img[$inputs['address']]["Blob_Content"]
){

    header('HTTP/1.0 200 Ok');

    header("Content-Type: " . $img[$inputs['address']]["Data_Type"]);

    //If a user requested a resource with a specific 'lastChanged' time, it is safe to assume he'll get a different one (thus different URL) once the image changes
    if($inputs['lastChanged'] !== null){
        header('Cache-Control: public, max-age=241920000, immutable');
        //Yeah, those fucking headers aren't gonna ruin my cache control
        header('Expires: '.date("r", (time()+241920000)));
        //Yes, I am aware only "no-cache" is valid
        header('Pragma: cache');

    }
    else{
        header('Cache-Control: no-store');
    }


    $meta = $img[$inputs['address']]['Text_Content'];
    if(\IOFrame\Util\is_json($meta)){
        if(isset($meta['size']))
            header("Content-Length: " . $meta['size']);
    }

    die(base64_decode($img[$inputs['address']]["Blob_Content"]));
}
else{
    header("HTTP/1.1 404 No Media Found");
    die();
}