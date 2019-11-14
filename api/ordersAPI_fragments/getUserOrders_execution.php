<?php

$params = [
    'getLimitedInfo' =>$inputs['getLimitedInfo'],
    'returnLimitedOrders' =>$inputs['returnLimitedOrders'],
    'relationType'=>$inputs['relationType'],
    'orderBy'=>$inputs['orderBy'],
    'limit'=>$inputs['limit'],
    'offset'=>$inputs['offset'],
    'createdAfter'=>$inputs['createdAfter'],
    'createdBefore'=>$inputs['createdBefore'],
    'changedAfter'=>$inputs['changedAfter'],
    'changedBefore'=>$inputs['changedBefore'],
    'test'=>$test,
];

$result = $PurchaseOrderHandler->getUserOrders(
    $inputs['userID'],
    $params
);