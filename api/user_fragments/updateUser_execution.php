<?php

require_once __DIR__.'/../../IOFrame/Handlers/UserHandler.php';
$UserHandler = new \IOFrame\Handlers\UserHandler($settings,['SQLHandler'=>$SQLHandler]);

$result = $UserHandler->updateUser(
    $inputs['id'],
    [
        'username' =>$inputs['username'],
        'email' => $inputs['email'],
        'active' => $inputs['active'],
        'created' => $inputs['created'],
        'bannedDate' =>$inputs['bannedDate'],
        'suspiciousDate' =>$inputs['suspiciousDate']
    ],
    'ID',
    ['test'=>$test]
);