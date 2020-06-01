<?php

require_once __DIR__.'/../../IOFrame/Handlers/UserHandler.php';
$UserHandler = new \IOFrame\Handlers\UserHandler($settings,['SQLHandler'=>$SQLHandler]);

$result = $UserHandler->getUsers([
    'idAtLeast' =>$inputs['idAtLeast'],
    'idAtMost' => $inputs['idAtMost'],
    'rankAtLeast' => $inputs['rankAtLeast'],
    'rankAtMost' => $inputs['rankAtMost'],
    'usernameLike' =>$inputs['usernameLike'],
    'emailLike' =>$inputs['emailLike'],
    'isActive' => $inputs['isActive'],
    'isBanned' =>$inputs['isBanned'],
    'isSuspicious' => $inputs['isSuspicious'],
    'createdBefore' => $inputs['createdBefore'],
    'createdAfter' => $inputs['createdAfter'],
    'orderBy' =>$inputs['orderBy'],
    'orderType' => $inputs['orderType'],
    'limit' =>$inputs['limit'],
    'offset' =>$inputs['offset'],
    'test'=>$test
]);

$tempRes = [];

if(is_array($result))
    foreach($result as $id=>$res){
        if($id === '@')
            $tempRes[$id] = $res;
        else
            $tempRes[$id] = [
                    'id'=>$res['ID'],
                    'username'=>$res['Username'],
                    'email'=>$res['Email'],
                    'active'=>$res['Active']? true : false,
                    'rank'=>$res['Auth_Rank'],
                    'created'=>DateTime::createFromFormat('YmdHis', $res['Created_On'])->getTimestamp(),
                    'bannedUntil'=>(int)$res['Banned_Until'],
                    'suspiciousUntil'=>(int)$res['Suspicious_Until']
            ];
    }

$result = $tempRes;