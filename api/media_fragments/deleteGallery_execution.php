<?php
if(!defined('FrontEndResourceHandler'))
    require __DIR__ . '/../../IOFrame/Handlers/FrontEndResourceHandler.php';

//Handlers
$FrontEndResourceHandler = new IOFrame\Handlers\FrontEndResourceHandler($settings,$defaultSettingsParams);

$result = $FrontEndResourceHandler->deleteFrontendResourceCollection(
    $inputs['gallery'],
    ($action === 'setGallery' ? 'img':'vid'),
    [ 'test'=>$test]
);
