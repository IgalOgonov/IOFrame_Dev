<?php

require __DIR__.'/../../IOFrame/Handlers/TreeHandler.php';
$TreeHandler = new \IOFrame\Handlers\TreeHandler(
    ['test_euler_tree1'=>0,'test_euler_tree2'=>0]
    ,$settings,
    ['SQLHandler'=>$SQLHandler,'logger'=>$logger,'RedisHandler'=>$RedisHandler,'test'=>true]
);
//$TreeHandler->removeTrees(['test_euler_tree1'=>['updateDB'=>true],'test_euler_tree2'=>['updateDB'=>true]],false);
//Represents few of the trees in the dev/Docs/Euler.jpg image


$testEulerTree1 = [
    0 => [
        "content" => 'Root / Node 0',
        "smallestEdge" => 1,
        "largestEdge" => 8
    ],
    1 => [
        "content" => 'Node 1',
        "smallestEdge" => 1,
        "largestEdge" => 2
    ],
    2 => [
        "content" => 'Node 2',
        "smallestEdge" => 3,
        "largestEdge" => 4
    ],
    3 => [
        "content" => 'Node 3',
        "smallestEdge" => 5,
        "largestEdge" => 8
    ],
    4 => [
        "content" => 'Node 4',
        "smallestEdge" => 6,
        "largestEdge" => 7
    ],
];

$testEulerTree2 = [
    0 => [
        "content" => 'Root / Node 0',
        "smallestEdge" => 1,
        "largestEdge" => 8
    ],
    1 => [
        "content" => 'Node 1',
        "smallestEdge" => 1,
        "largestEdge" => 6
    ],
    2 => [
        "content" => 'Node 2',
        "smallestEdge" => 2,
        "largestEdge" => 3
    ],
    3 => [
        "content" => 'Node 3',
        "smallestEdge" => 4,
        "largestEdge" => 5
    ],
    4 => [
        "content" => 'Node 4',
        "smallestEdge" => 7,
        "largestEdge" => 8
    ],
];

/*
for($i=0; $i<5; $i++){
    if(isset($_REQUEST['test'.$i]))
        $testEulerTree1[$i]['content'] = $_REQUEST['test'.$i];
}

$TreeHandler->addTrees([
    'test_euler_tree2'=>['content'=>$testEulerTree2,'updateDB'=>true]
],
['test'=>false]
);

$TreeHandler->addTrees([
    'test_euler_tree1'=>['content'=>$testEulerTree1,'private'=>true,'updateDB'=>true]
],
['test'=>false]
);

*/

echo EOL.'test_euler_tree2 euler:'.EOL;
var_dump($TreeHandler->getTree('test_euler_tree2'));

echo EOL.'test_euler_tree2 assoc:'.EOL;
var_dump($TreeHandler->getAssocTree('test_euler_tree2'));

echo EOL.'test_euler_tree1 assoc - with private check:'.EOL;
var_dump($TreeHandler->eulerToAssoc($TreeHandler->getTree('test_euler_tree1')));
$TreeHandler->getFromDB(['test_euler_tree1'=>0],['ignorePrivate'=>false, 'test'=>true]);

echo EOL.'test_euler_tree1 assoc - without private check:'.EOL;
var_dump($TreeHandler->eulerToAssoc($TreeHandler->getTree('test_euler_tree1')));

echo EOL.'Linking a new node to node 4 in test_euler_tree1'.EOL;
var_dump(
    $TreeHandler->linkNodesToID(
        'test_euler_tree1',
        [
            0 => [
                "content" => 'test',
                "smallestEdge" => 0,
                "largestEdge" => 0
            ]
        ],
        4,
        ['updateDB'=>true,'childNum'=>1,'test'=>true]
    )
);

echo EOL.'Linking test_euler_tree1 to test_euler_tree2'.EOL;
var_dump(
    $TreeHandler->linkNodesToID('test_euler_tree2',$testEulerTree1,1,['updateDB'=>true,'childNum'=>1,'test'=>true])
);

echo EOL.'Cutting node 2 from test_euler_tree2'.EOL;
var_dump(
    $TreeHandler->cutNodesByID('test_euler_tree2',2,['updateDB'=>true,'test'=>true])
);


