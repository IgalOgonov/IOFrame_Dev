<?php
if(!defined('FrontEndResourceHandler'))
    require __DIR__ . '/../../IOFrame/Handlers/FrontEndResourceHandler.php';

//Handlers
$FrontEndResourceHandler = new IOFrame\Handlers\FrontEndResourceHandler($settings,$defaultSettingsParams);


$copy = $inputs['copy'];

$result = $inputs['remote'] ?
    $FrontEndResourceHandler->renameResource(
        $inputs['oldAddress'],
        $inputs['newAddress'],
        'img',
        ['test'=>$test, 'copy'=>$copy]
    ):
    $FrontEndResourceHandler->moveImage(
        $inputs['oldAddress'],
        $inputs['newAddress'],
        ['test'=>$test, 'copy'=>$copy]
    );