<?php

require_once __DIR__.'/../../IOFrame/Handlers/ObjectHandler.php';
$extraColumnsToGet = [
    //'Trusted_Comment'
];
$extraColumnsToSet = [
    //['Trusted_Comment',0]
];
$extraContentUpdate = [
    //9=>[0],
    //13=>[1],
    //14=>[]
];
$extraContentAdd = [
    //[0],
    //[1],
    //[]
];
$objHandler = new IOFrame\Handlers\ObjectHandler($settings,['SQLHandler' => $SQLHandler, 'RedisHandler' => $RedisHandler, 'logger' => $logger]);

echo 'Getting objects in group cources:'.EOL;
var_dump($objHandler->getObjectsByGroup('courses',['extraColumns'=>$extraColumnsToGet,'test'=>true]));
echo EOL;

echo 'Adding object test01_@#$_(){}[]:'.EOL;
var_dump($objHandler->addObject('test01_@#$_(){}[]','g4',12,2,['test'=>true]));
echo EOL;

echo 'Adding object test02:'.EOL;
var_dump($objHandler->addObject('test02','g5',5,6,['test'=>true]));
echo EOL;

echo 'Adding object test05:'.EOL;
var_dump($objHandler->addObject('test05','g2',10,15,['test'=>true]));
echo EOL;

echo 'Adding object "Test":"All clear","Fucks To Give":0}:'.EOL;
var_dump($objHandler->addObject('{"Test":"All clear","Fucks To Give":0}','',0,-1,['test'=>true]));
echo EOL;

echo 'Adding objects Test Object 1m Test Object 2, Test Object 3:'.EOL;
$arr = [
    ['Test Object 1', 'g1'],
    ['Test Object 2', '',5,5],
    ['Test Object 3', 'g4',0,0],
];
var_dump($objHandler->addObjects(
    $arr,
    [
        'extraColumns'=>$extraColumnsToSet,
        'extraContent'=>$extraContentAdd,
        'test'=>true
    ]
));
echo EOL;

echo 'Getting objects 9,13,14:'.EOL;
$arr = [[9,0],[13,0],[14,0]];
var_dump($objHandler->getObjects($arr, ['extraColumns'=>$extraColumnsToGet,'test'=>true]));
echo EOL;

echo 'Getting object 9:'.EOL;
var_dump($objHandler->getObject(9,0, ['extraColumns'=>$extraColumnsToGet,'test'=>true]));
echo EOL;

echo 'Getting object 9 but without safeStr:'.EOL;
var_dump($objHandler->getObject(9,0, ['safeStr'=>false,'extraColumns'=>$extraColumnsToGet,'test'=>true]));
echo EOL;

echo 'Deleting: object 8, object 9 if it was updated before 1500000000, 10 if it was updated after 1500000000,
        0 if it was updated after 1500000000:'.EOL;
var_dump(
    $objHandler->deleteObjects(
        [[8, 0,true],[9, 1500000000,false],[10, 1500000000,true],[0, 1500000000,true]],
        ['test'=>true])
);
echo EOL;

echo 'Updating objects 9,13,14:'.EOL;
var_dump($objHandler->updateObjects(
    [
        [9, '{test:"{"test2":"testValue"}"}','g2',null,null,null,[],[]],
        [13, '','',-1,null,null,[],[]],
        [14, '',null,-1,null,null,[],[]],
    ],
    [
        'extraColumns'=>$extraColumnsToSet,
        'extraContent'=>$extraContentUpdate,
        'test'=>true
    ]
));
echo EOL;

echo 'Updating object 9:'.EOL;
var_dump($objHandler->updateObject(9, 'Test content!**^', 'g2', -1, 2,1, [2=>2,3=>3], [4=>4,3=>3], ['test'=>true]));
echo EOL;

echo 'Updating object 8:'.EOL;
var_dump($objHandler->updateObject(8, '', '', 5, null,null, [], [], ['test'=>true]));
echo EOL;


echo 'Getting groups g1,g2,g3:'.EOL;
$groups = $objHandler->retrieveGroups(['g2','g1','g3'],['test'=>true]);
var_dump($groups);
echo EOL;

echo 'Updating last changed of groups g1,g2,g3:'.EOL;
$groupArray=[];
foreach($groups as $group=>$info){
    array_push($groupArray,$group);
}
var_dump($objHandler->updateGroups($groupArray, ['test'=>true]));
echo EOL;

echo 'Checking whether group g1 was updated after 1522276536:'.EOL;
var_dump($objHandler->checkGroupUpdated('g1',1522276536,['test'=>true]));
echo EOL;

echo 'Getting object map CV:'.EOL;
var_dump($objHandler->getObjectMap('CV',['test'=>true,'time'=>0]));
echo EOL;

echo 'Getting object map CV but only if it was changed after 1622276536:'.EOL;
var_dump($objHandler->getObjectMap('CV',['test'=>true,'time'=>1622276536]));
echo EOL;

echo 'Getting object maps CV, cp/objects.php, testpage:'.EOL;
var_dump(json_encode($objHandler->getObjectMaps(['CV'=>0,'cp/objects.php'=>0,'testpage'=>0],['test'=>true])));
echo EOL;

echo 'Assigning object 10 to test.php:'.EOL;
var_dump($objHandler->objectMapModify(10,'test.php', true, ['test'=>true]));
echo EOL;

echo 'Assigning object 10 to CV:'.EOL;
var_dump($objHandler->objectMapModify(10,'CV', true, ['test'=>true]));
echo EOL;

echo 'Removing 9,14 from cp/objects.php:'.EOL;
var_dump(  $objHandler->objectMapModifyMultiple(
    [[9,'cp/objects.php', false], [14,'cp/objects.php', false]], ['test'=>true]));
echo EOL;

echo 'Removing 9 from cp/objects.php, adding 13 to CV:'.EOL;
var_dump( $objHandler->objectMapModifyMultiple(
    [[9,'cp/objects.php', false], [13,'CV', true]], ['test'=>true]));
echo EOL;

echo 'Removing 9,14 from cp/objects.php, adding 14 to CV:'.EOL;
var_dump( $objHandler->objectMapModifyMultiple(
    [[9,'cp/objects.php', false], [14,'cp/objects.php', false], [14,'CV', true]], ['test'=>true]));
echo EOL;