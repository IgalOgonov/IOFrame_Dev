<?php
$ResourceHandler = new IOFrame\Handlers\ResourceHandler($settings,$defaultSettingsParams);
$IOFrameJSRoot = 'front/ioframe/js/';
$IOFrameCSSRoot = 'front/ioframe/css/';


echo 'Setting resources:'.EOL;
var_dump($ResourceHandler->setResources(
    [
        ['sec/aes.js'],
        ['sec/mode-ecb.js'],
        ['sec/mode-ctr.js'],
        ['sec/pad-ansix923-min.js'],
        ['sec/pad-zeropadding.js'],
        ['utils.js'],
        ['initPage.js'],
        ['objects.js'],
        ['fp.js'],
        ['ezAlert.js']
    ],
    'js',
    ['test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameJSRoot])
);
echo EOL;

echo 'Setting resources (override false):'.EOL;
var_dump($ResourceHandler->setResources(
    [
        ['fp.js',false,false],
        ['newStuff.js',false,false,'test 1!@#@']
    ],
    'js',
    ['test'=>true,'verbose'=>true,'override'=>false,'rootFolder'=>$IOFrameJSRoot])
);
echo EOL;

echo 'Setting resources (override true):'.EOL;
var_dump($ResourceHandler->setResources(
    [
        ['fp.js',false,false,'<script>alert("hello!")</script>']
    ],
    'js',
    ['test'=>true,'verbose'=>true,'override'=>true,'rootFolder'=>$IOFrameJSRoot])
);
echo EOL;

echo 'Renaming existing resource:'.EOL;
var_dump($ResourceHandler->renameResource(
    'fp.js',
    'fp2.js',
    'js',
    ['test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameJSRoot])
);
echo EOL;

echo 'Renaming unexisting resource:'.EOL;
var_dump($ResourceHandler->renameResource(
    'nothing.js',
    'nothing2.js',
    'js',
    ['test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameJSRoot])
);
echo EOL;

echo 'Deleting existing and unexisting resources:'.EOL;
var_dump($ResourceHandler->deleteResources(
    ['nothing.js','fp.js','utils.js'],
    'js',
    ['test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameJSRoot])
);
echo EOL;

echo  'Incrementing versions of existing and unexisting resources:'.EOL;
var_dump($ResourceHandler->incrementResourcesVersions(
    ['nothing.js','fp.js','utils.js'],
    'js',
    ['test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameJSRoot])
);
echo EOL;

echo 'Getting all js resources with no conditions:'.EOL;
var_dump($ResourceHandler->getResources([],'js',['test'=>true,'verbose'=>true]));
echo EOL;

echo  'Getting all resources with conditions:'.EOL;
var_dump($ResourceHandler->getResources(
    [],
    'js',
    [
        'createdAfter'=>0,
        'createdBefore'=>9563498189,
        'changedAfter'=>0,
        'changedBefore'=>9563498189,
        'includeRegex'=>'sec\/',
        'excludeRegex'=>'mode',
        'ignoreLocal'=>false,
        'onlyLocal'=>true,
        'rootFolder'=>$IOFrameJSRoot,
        'test'=>true,
        'verbose'=>true
    ]
));
echo EOL;

echo 'Getting existing resources with conditions:'.EOL;
var_dump($ResourceHandler->getResources(
    ['ezAlert.js','fp.js','sec/mode-ctr.js','sec/aes.js','utils.js'],
    'js',
    [
        'createdAfter'=>0,
        'createdBefore'=>9563498189,
        'changedAfter'=>0,
        'changedBefore'=>9563498189,
        'excludeRegex'=>'mode',
        'ignoreLocal'=>false,
        'onlyLocal'=>true,
        'rootFolder'=>$IOFrameJSRoot,
        'test'=>true,
        'verbose'=>true
    ]
));
echo EOL;


echo 'Creating core JS class:'.EOL;
var_dump($ResourceHandler->setResourceCollection('IOFrameCoreJS','js',null,['test'=>true,'verbose'=>true]));
echo EOL;

echo 'Adding core JS resources to collection (no push to order):'.EOL;
var_dump($ResourceHandler->addResourcesToCollection(
    ['sec/aes.js','sec/mode-ecb.js','sec/mode-ctr.js','sec/pad-ansix923-min.js','sec/pad-zeropadding.js',
        'utils.js','initPage.js','objects.js','fp.js','ezAlert.js'],
    'IOFrameCoreJS',
    'js',
    ['test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameJSRoot])
);
echo EOL;

echo 'Adding core JS resources to collection (push to order):'.EOL;
var_dump($ResourceHandler->addResourcesToCollection(
    ['sec/aes.js','sec/mode-ecb.js','sec/mode-ctr.js','sec/pad-ansix923-min.js','sec/pad-zeropadding.js',
        'utils.js','initPage.js','objects.js','fp.js','ezAlert.js'],
    'IOFrameCoreJS',
    'js',
    ['test'=>true,'verbose'=>true,'pushToOrder'=>true,'rootFolder'=>$IOFrameJSRoot])
);
echo EOL;

echo 'Adding core JS resources to unexisting collection (push to order):'.EOL;
var_dump($ResourceHandler->addResourcesToCollection(
    ['sec/aes.js','sec/mode-ecb.js','sec/mode-ctr.js','sec/pad-ansix923-min.js','sec/pad-zeropadding.js',
        'utils.js','initPage.js','objects.js','fp.js','ezAlert.js'],
    'asfg43fgsddgsdg',
    'js',
    ['test'=>true,'verbose'=>true,'pushToOrder'=>true,'rootFolder'=>$IOFrameJSRoot])
);
echo EOL;

echo 'Adding unexisting and existing resources to collection:'.EOL;
var_dump($ResourceHandler->addResourcesToCollection(
    ['test','gfsg4wtsf'],
    'IOFrameCoreJS',
    'js',
    ['test'=>true,'verbose'=>true])
);
echo EOL;

echo 'Removing unexisting and existing resources from collection (order included):'.EOL;
var_dump($ResourceHandler->removeResourcesFromCollection(
    ['test','gfsg4wtsf','utils.js','fp.js'],
    'IOFrameCoreJS',
    'js',
    ['test'=>true,'verbose'=>true,'removeFromOrder'=>true,'rootFolder'=>$IOFrameJSRoot])
);
echo EOL;

echo 'Getting one resource collection:'.EOL;
var_dump(
    $ResourceHandler->getResourceCollection(
        'IOFrameCoreJS',
        'js',
        ['getMembers'=>true,'test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameJSRoot]
    )
);
echo EOL;

echo 'Getting all resource collections:'.EOL;
var_dump(
    $ResourceHandler->getResourceCollections(
        [],
        'js',
        ['test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameJSRoot]
    )
);
echo EOL;

echo 'Getting unexisting resource collections:'.EOL;
var_dump(
    $ResourceHandler->getResourceCollections(
        ['test','gfsg4wtsf'],
        'js',
        ['getMembers'=>true,'test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameJSRoot]
    )
);
echo EOL;

echo 'Moving index 2 to 5 in an existing collection:'.EOL;
var_dump(
    $ResourceHandler->moveCollectionOrder(
        2,
        5,
        'IOFrameCoreJS',
        'js',
        ['test'=>true,'verbose'=>true,'removeFromOrder'=>true,'rootFolder'=>$IOFrameJSRoot]
    )
);
echo EOL;

echo 'Swapping indexes 2 and 5 in an existing collection:'.EOL;
var_dump(
    $ResourceHandler->swapCollectionOrder(
        2,
        5,
        'IOFrameCoreJS',
        'js',
        ['test'=>true,'verbose'=>true,'removeFromOrder'=>true,'rootFolder'=>$IOFrameJSRoot]
    )
);
echo EOL;

echo 'Adding all members of IOFrameCoreJS to its order:'.EOL;
var_dump(
    $ResourceHandler->addAllToCollectionOrder(
        'IOFrameCoreJS',
        'js',
        ['test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameJSRoot]
    )
);
echo EOL;

echo 'Removing IOFrameCoreJS order:'.EOL;
var_dump(
    $ResourceHandler->removeAllFromCollectionOrder(
        'IOFrameCoreJS',
        'js',
        ['test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameJSRoot]
    )
);
echo EOL;
