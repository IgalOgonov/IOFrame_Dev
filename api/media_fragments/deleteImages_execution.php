<?php
if(!defined('FrontEndResourceHandler'))
    require __DIR__ . '/../../IOFrame/Handlers/FrontEndResourceHandler.php';

//Handlers
$FrontEndResourceHandler = new IOFrame\Handlers\FrontEndResourceHandler($settings,$defaultSettingsParams);

$result = $inputs['remote'] ?
    $FrontEndResourceHandler->deleteResources(
        $inputs['addresses'],
        'img',
        ['test' => $test]
    ) :
    $FrontEndResourceHandler->deleteImages(
        $inputs['addresses'],
        ['test' => $test]
    );