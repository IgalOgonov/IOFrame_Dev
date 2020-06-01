<?php
if(!defined('UploadHandler'))
    require __DIR__ . '/../../IOFrame/Handlers/UploadHandler.php';
if(!defined('FrontEndResourceHandler'))
    require __DIR__ . '/../../IOFrame/Handlers/FrontEndResourceHandler.php';

//Handlers
$UploadHandler = new \IOFrame\Handlers\UploadHandler($settings,$defaultSettingsParams);
$FrontEndResourceHandler = new IOFrame\Handlers\FrontEndResourceHandler($settings,$defaultSettingsParams);

$uploadNames = [];
foreach($inputs['items'] as $uploadName => $item){
    if($inputs['type'] === 'link'){
        $result[$uploadName] = $item['filename'];
    }
    elseif(isset($item['filename']))
        array_push($uploadNames,['uploadName'=>$uploadName,'requestedName'=>$item['filename']]);
    else
        array_push($uploadNames,['uploadName'=>$uploadName]);
}

if($inputs['type'] !== 'link')
    $result = $UploadHandler->handleUploadedFile(
        $uploadNames,
        [
            'resourceOpMode'=> ($inputs['type'] === 'local' ? 'local' : 'data'),
            'test'=>$test,
            'verbose'=>$test,
            'overwrite'=>$inputs['overwrite'] && !$test,
            'imageQualityPercentage'=>$inputs['imageQualityPercentage'],
            'resourceTargetPath'=>$resourceSettings->getSetting('imagePathLocal').$inputs['address'],
            'maxFileSize' => $siteSettings->getSetting('maxUploadSize'),
        ]);

$mediaToUpdate = [];
$mediaToAddToGallery = [];
$deleteLocalFiles = [];
$errorCodes = [-2,-1,0,1,2,3,4];
$dbToUploadMap = [];
$uploadToDBMap = [];

//Parse the results
foreach($result as $uploadName => $res){

    //The following happens if the mode is local
    if($inputs['type'] === 'local'){
        //If we are testing and couldn't overwrite an existing file, assume we created it
        $fakeFile = false;
        if( ($res === 2) && $inputs['overwrite'] && $test){
            $fakeFile = true;
            $res = $resourceSettings->getSetting('imagePathLocal').$inputs['address'].$uploadName.'_TEST.test';
            $result[$uploadName] = $res;
        }

        //The DB name wont have the image path in it
        $DBName = substr($res,strlen($resourceSettings->getSetting('imagePathLocal')));
    }
    //The following happens if the type is db
    elseif($inputs['type'] === 'db'){
        //Either way, the only thing that matters is the upload name
        $DBName = $uploadName;
    }
    //And finally, for links
    elseif($inputs['type'] === 'link'){
        //Either way, the only thing that matters is the upload name
        $DBName = $res;
    }

    $dbToUploadMap[$DBName] = $uploadName;
    $uploadToDBMap[$uploadName] = $DBName;

    //Only do this if the result isn't an error code
    if(!in_array($res,$errorCodes, true)){

        //Push local files to delete if we fail the DB update or if we're testing
        if($inputs['type'] === 'local' && !$fakeFile)
            $deleteLocalFiles[$uploadName] = $rootFolder.$res;

        //Meta information
        $alt  = isset($inputs['items'][$uploadName]['alt'])? $inputs['items'][$uploadName]['alt'] : null;
        $name  = isset($inputs['items'][$uploadName]['name'])? $inputs['items'][$uploadName]['name'] : null;
        $caption  = isset($inputs['items'][$uploadName]['caption'])? $inputs['items'][$uploadName]['caption'] : null;
        $size  = $inputs['type'] === 'db' ? $res['size'] : null;
        if($alt || $name || $caption || $size){
            $meta = [];
            if($alt)
                $meta['alt'] = $alt;
            if($name)
                $meta['name'] = $name;
            if($caption)
                $meta['caption'] = $caption;
            if($size)
                $meta['size'] = $size;
            $meta = json_encode($meta);
        }
            else
                $meta = null;
        //Add resources to be updated
        array_push(
            $mediaToUpdate,
            [
                'address'=>$DBName,
                'local'=>$inputs['type'] === 'local',
                'minified'=>false,
                'text'=>$meta,
                'blob'=>($inputs['type'] === 'db'? $res['data'] : null),
                'dataType'=>($inputs['type'] === 'db'? $res['type'] : null),
            ]
        );
    }

}

//Update the resources
if($mediaToUpdate != [])
    $updateDB =  $FrontEndResourceHandler->setResources(
        $mediaToUpdate,
        'img',
        ['test'=>$test]
    );
else
    foreach($result as $uploadName => $res){
        $updateDB[$uploadToDBMap[$uploadName]] = 0;
    }

foreach($updateDB as $DBName => $resultCode){
    if($resultCode === 0 ){
        //If gallery is not null, we remove the deletion request there. If this is a test, always delete
        if($inputs['type'] === 'local' && !$test && $inputs['gallery'] === null)
            unset($deleteLocalFiles[$dbToUploadMap[$DBName]]);
        //Add each image to gallery, if requested
        if($inputs['gallery'] !== null){
            array_push(
                $mediaToAddToGallery,
                $DBName
            );
        }
        //If we were uploading to the db, change the horrible result array into a simple code
        if($inputs['type'] === 'db')
            $result[$dbToUploadMap[$DBName]] = $resultCode;
    }
    else{
        //Update results
        if($resultCode < 0)
            $result[$dbToUploadMap[$DBName]] = $resultCode;
        else
            $result[$dbToUploadMap[$DBName]] = 104;
    }
}

//Update the gallery if requested
if($mediaToAddToGallery != []){
    $updateDB =  $FrontEndResourceHandler->addImagesToGallery(
        $mediaToAddToGallery,
        $inputs['gallery'],
        ['test'=>$test,]
    );

    foreach($updateDB as $DBName => $resultCode){
        if($resultCode === 0 || $test){
            //If this is a test, always delete
            if($inputs['type'] === 'local' && !$test)
                unset($deleteLocalFiles[$dbToUploadMap[$DBName]]);
        }
        else
            $result[$dbToUploadMap[$DBName]] = 105;
    }

}

//Delete files that we still need to delete
foreach($deleteLocalFiles as $uploadName => $addr){
    if(!$test)
        unlink($addr);
    else
        echo 'Deleting file at '.$addr.EOL;
}
