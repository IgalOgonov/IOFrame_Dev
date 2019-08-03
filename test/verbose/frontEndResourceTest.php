<?php


$FrontEndResourceHandler = new IOFrame\Handlers\FrontEndResourceHandler($settings,$defaultSettingsParams);

echo 'Getting ALL js files in the root folder (and remote ones):'.EOL;
var_dump(
    $FrontEndResourceHandler->getJS([],['test'=>true,'verbose'=>true])
);
echo EOL;

echo 'Getting existing JS files, some in the DB some not:'.EOL;
var_dump(
    $FrontEndResourceHandler->getJS(['config.js','fp.js','initPage.js','sec/aes.js'],['test'=>true,'verbose'=>true])
);
echo EOL;

echo 'Getting existing JS files and folders, none in the db:'.EOL;
var_dump(
    $FrontEndResourceHandler->getJS(['config.js','fp.js','initPage.js','modules'],['test'=>true,'verbose'=>true])
);
echo EOL;

echo 'Moving JS files, some exist (in filesystem/db), some dont'.EOL;
var_dump(
    $FrontEndResourceHandler->moveJSFiles(
        [
            ['config.js','test/config.js'],
            ['fp.js','test/fp.js'],
            ['fake.js','stillFake.js'],
        ],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Deleting JS files, some exist (in filesystem/db), some dont'.EOL;
var_dump(
    $FrontEndResourceHandler->deleteJSFiles(
        [
            'config.js',
            'crypto/md5.js',
            'fake.js',
        ],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Minifying local JS files, some exist, some dont - no common name'.EOL;
var_dump(
    $FrontEndResourceHandler->minifyJSFiles(
        [
            'config.js',
            'crypto/md5.js',
            'fake.js',
        ],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Getting JS collection IOFrameCoreJS'.EOL;
var_dump(
    $FrontEndResourceHandler->getJSCollections(
        [
            'IOFrameCoreJS'
        ],
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Compiling fake SCSS to folder'.EOL;
var_dump(
    $FrontEndResourceHandler->compileSCSS(
        'fake.scss',
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Compiling SCSS'.EOL;
var_dump(
    $FrontEndResourceHandler->compileSCSS(
        'test.scss',
        ['test'=>true,'verbose'=>true]
    )
);
echo EOL;

echo 'Compiling SCSS to folder'.EOL;
var_dump(
    $FrontEndResourceHandler->compileSCSS(
        'test.scss',
        ['test'=>true,'verbose'=>true,'compileToFolder'=>'scss']
    )
);
echo EOL;

echo 'Getting SCSS, CSS, and a folder that contains both'.EOL;
var_dump(
    $FrontEndResourceHandler->getCSS(
        ['test.scss','test'],
        ['test'=>true,'verbose'=>true,'compileToFolder'=>'scss']
    )
);
echo EOL;