<?php

require_once __DIR__.'/../../IOFrame/Handlers/UserHandler.php';
$UserHandler = new \IOFrame\Handlers\UserHandler($settings,['SQLHandler'=>$SQLHandler]);

echo EOL.'Getting all users with many parameters'.EOL;
var_dump($UserHandler->getUsers([
    'idAtLeast' =>1,
    'idAtMost' => 3,
    'rankAtLeast' => 0,
    'rankAtMost' => 10000,
    'usernameLike' =>'A',
    'emailLike' =>'.com',
    'isActive' => true,
    'isBanned' =>false,
    'isSuspicious' => false,
    'createdBefore' => 999999999999,
    'createdAfter' => 0,
    'orderBy' =>'Email',
    'orderType' => 0,
    'limit' =>5,
    'offset' =>0,
    'test'=>true
]));

echo EOL.'Updating user 1 with all possible parameters'.EOL;
var_dump($UserHandler->updateUser(
    1,
    [
        'username' =>'Test Username',
        'email' => 'test@test.com',
        'active' => 1,
        'created' => 99999999999,
        'bannedDate' =>99999999999
    ],
    'ID',
    ['test'=>true]
));
echo EOL.'Updating user 1 with 1 parameter'.EOL;
var_dump($UserHandler->updateUser(
    1,
    [
        'username' =>'Test Username'
    ],
    'ID',
    ['test'=>true]
));

echo EOL.'Changing password of user 1 to R43W32E43Q65:'.EOL;
var_dump($UserHandler->changePassword(1,'R43W32E43Q65',['test'=>true]));

echo EOL.'Changing email of user 1 to test@test.com:'.EOL;
var_dump($UserHandler->changeMail(1,'test@test.com',['test'=>true]));
echo EOL;

echo EOL.'Checks whether user 1 can be logged into:'.EOL;
var_dump($UserHandler->checkUserLogin(1,['test'=>true]));
echo EOL;

echo EOL.'Checks whether unexisting user can be logged into:'.EOL;
var_dump($UserHandler->checkUserLogin('fake@mail.com',['test'=>true]));
echo EOL;

echo EOL.'Checks whether user one can log in - checks a fake code an a fake IP:'.EOL;
echo $UserHandler->checkUserLogin(1,['allowCode'=>'code','allowWhitelistedIP'=>'0.1.2.3','test'=>true]).EOL;
