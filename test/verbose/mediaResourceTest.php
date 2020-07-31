<?php
if(!isset($FrontEndResourceHandler))
    $FrontEndResourceHandler = new IOFrame\Handlers\FrontEndResourceHandler($settings,$defaultSettingsParams);
$IOFrameIMGRoot = 'front/ioframe/img/';

echo 'Creating test gallery'.EOL;
var_dump(
    $FrontEndResourceHandler->setGallery('Test Gallery',null,['test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameIMGRoot])
);
echo EOL.EOL;

echo 'Updating test gallery with a name'.EOL;
var_dump(
    $FrontEndResourceHandler->setGallery(
        'Test Gallery',
        json_encode(['name'=>'Awesome Gallery']),
        ['test'=>true,'verbose'=>true,'update'=>true,'rootFolder'=>$IOFrameIMGRoot]
    )
);
echo EOL.EOL;

echo 'Updating test gallery with a tea color'.EOL;
var_dump(
    $FrontEndResourceHandler->setGallery(
        'Test Gallery',
        json_encode(['tea color'=>'Green']),
        ['test'=>true,'verbose'=>true,'update'=>true,'rootFolder'=>$IOFrameIMGRoot]
    )
);
echo EOL.EOL;

echo 'Getting plugins folder and a single image as well'.EOL;
var_dump(
    $FrontEndResourceHandler->getImages(
        ['docs/Euler.png','pluginImages'],
        ['test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameIMGRoot]
    )
);
echo EOL.EOL;

echo 'Setting image name and alt tag:'.EOL;
var_dump(
    $FrontEndResourceHandler->setResources(
        [
            [
                'address'=>'docs/Euler.png',
                'local'=>false,
                'minified'=>false,
                'text'=>json_encode(['alt'=>'Alternative Title','name'=>'Prettier Name'])
            ]
        ],
        'img',
        ['test'=>true,'verbose'=>true,'update'=>true,'rootFolder'=>$IOFrameIMGRoot])
);
echo EOL.EOL;

echo 'Changing image name:'.EOL;
var_dump(
    $FrontEndResourceHandler->setResources(
        [
            [
                'address'=>'docs/Euler.png',
                'local'=>false,
                'minified'=>false,
                'text'=>json_encode(['name'=>'Prettier Name'])
            ]
        ],
        'img',
        ['test'=>true,'verbose'=>true,'update'=>true,'rootFolder'=>$IOFrameIMGRoot])
);
echo EOL.EOL;

echo 'Adding single resource and a folder to gallery'.EOL;
var_dump(
    $FrontEndResourceHandler->addImagesToGallery(
        ['docs/Euler.png','docs/installScreenshots'],
        'Test Gallery',
        ['test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameIMGRoot]
    )
);
echo EOL.EOL;


echo 'Getting REMOTE media files:'.EOL;
var_dump(
    $FrontEndResourceHandler->getImages([],['test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameIMGRoot])
);
echo EOL.EOL;

echo 'Getting ALL LOCAL media files:'.EOL;
var_dump(
    $FrontEndResourceHandler->getImages([''],['test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameIMGRoot,'includeChildFolders'=>true,'includeChildFiles'=>true])
);
echo EOL.EOL;


echo 'Getting all galleries:'.EOL;
var_dump(
    $FrontEndResourceHandler->getGalleries([],['test'=>true,'verbose'=>true,'rootFolder'=>$IOFrameIMGRoot])
);
echo EOL.EOL;


echo 'Getting test gallery:'.EOL;
var_dump(
    $FrontEndResourceHandler->getGallery('Test Gallery',['test'=>true,'verbose'=>true,'includeGalleryInfo'=>true,'rootFolder'=>$IOFrameIMGRoot])
);
echo EOL.EOL;


echo 'Getting fake gallery:'.EOL;
var_dump(
    $FrontEndResourceHandler->getGallery('fake Gallery',['test'=>true,'verbose'=>true,'includeGalleryInfo'=>true,'rootFolder'=>$IOFrameIMGRoot])
);
echo EOL.EOL;


echo 'Getting fake gallery:'.EOL;
var_dump(
    $FrontEndResourceHandler->getGallery('fake Gallery',['test'=>true,'verbose'=>true,'includeGalleryInfo'=>true,'rootFolder'=>$IOFrameIMGRoot])
);
echo EOL.EOL;


echo 'Getting two real galleries AND their members:'.EOL;
var_dump(
    $FrontEndResourceHandler->getGalleries(['Test Gallery','Another Gallery'],['test'=>true,'verbose'=>true,'includeGalleryInfo'=>true,'rootFolder'=>$IOFrameIMGRoot])
);
echo EOL.EOL;
