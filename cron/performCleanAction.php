<?php
$allGood = true;
//Select a batch of relevant items
$results = $SQLHandler->selectFromTable(
    $SQLHandler->getSQLPrefix().$table['name'],
    [
        $table['expiresColumn'],
        time(),
        '<'
    ],
    $table['identifierColumns'],
    [
        'test'=>(bool)$parameters['test'],
        'verbose'=>(bool)$parameters['verbose'],
        'limit'=>$parameters['batchSize'],
        'orderBy'=>$table['expiresColumn'],
        'orderType'=>0,
    ]
);
//If selection failed, signify a retry
if(gettype($results) !== 'array'){
    $allGood = false;
    $parameters['tables'][$tableIndex]['retries']++;
}

//If no items are left, we are finished
if($allGood){
    if(count($results) === 0){
        $allGood = false;
        $parameters['tables'][$tableIndex]['finished'] = true;
    }
}

//Try to delete items
if($allGood){
    $stuffToDelete = [

    ];
    foreach ($results as $key=>$item){
        $itemToDelete = [];
        foreach ($table['identifierColumns'] as $col)
            array_push($itemToDelete,[$item[$col],'STRING']);
        array_push($itemToDelete,'CSV');
        array_push($stuffToDelete,$itemToDelete);
    }
    $deletion = $SQLHandler->deleteFromTable(
        $SQLHandler->getSQLPrefix().$table['name'],
        [
            $table['identifierColumns'],
            $stuffToDelete,
            'IN'
        ],
        [
            'test'=>(bool)$parameters['test'],
            'verbose'=>(bool)$parameters['verbose']
        ]
    );

    //If deletion worked, update successes, else retries
    if($deletion !== true){
        $parameters['tables'][$tableIndex]['retries']++;
    }
    else{
        $parameters['tables'][$tableIndex]['success']+=count($stuffToDelete);
    }
}

//If we were testing, finish after 1 iteration
if($parameters['test'])
    $parameters['tables'][$tableIndex]['finished'] = true;