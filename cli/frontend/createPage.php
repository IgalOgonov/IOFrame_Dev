<?php
/* Creates a generic Frontend page, and much more (depending on the request).
 * First of all, note that this specific script is only meant to create pages akin to the typical IOFrame frontend strucutre.
 * If you are looking to create different pages, you might consider using a different template handler.
 *
 * Examples:
 *      php pageCreator.php -h
 *      php pageCreator.php -t -f example.json
 *
 * ------- JSON Files & Templates -------
 * A template file is what defines how a page is created.
 * A JSON file sets some dynamic properties inside the template, and potentially decides which parts of the template
 * to use and which to discard.
 * The template structure is explain in templateFunctions.php - but, the explanation here is about the JSON file, and
 * specific use of template in IOFrame.
 * In very short, the templates provided by default (and used by this CLI)
 *
 * To understand the JSON file, read the documentation of the createPage() function in util.php in this folder.
 * */

if(php_sapi_name() != "cli"){
    die('This file must be accessed through the CLI!');
}

require __DIR__.'/../defaultInclude.php';
if(!defined('modificationFunctions'))
    require __DIR__ . '/../../IOFrame/Util/modificationFunctions.php';
if(!defined('templateFunctions'))
    require __DIR__ . '/../../IOFrame/Util/templateFunctions.php';
require 'util.php';

$baseUrl = $settings->getSetting('absPathToRoot').'cli/frontend/';
$jsonUrl = $baseUrl.'json/';
$templateUrl = $baseUrl.'templates/';

//-------------------- Get user options --------------------
$test = false;
$useOptionsFile = false;
$override = false;
$options = [];
$flags = getopt('f:htv',['feroot:','extrajson:']);
//Help message
if(isset($flags['h']))
    die('Available flags are:'.EOL.'
    -h Displays this help message'.EOL.'
    [REQUIRED]-f JSON file location RELATIVE to the root of the json folder
                 (in this folder). E.g "example.json"'.EOL.'
    [OPTIONAL]-t Test Mode '.EOL.'
    [OPTIONAL]-v Verbose output '.EOL.'
    [OPTIONAL]--feroot Frontend root, relative to server root -
                       default "front/ioframe/"'.EOL.'
    [OPTIONAL]--extrajson If provided, will recursively override anything
                          in the chosen template.
                          Strings (inc. keys) need to be enclosed in single brackets.
                          For example, {\'parameters\':{\'title\':\'Title 2\'}} would
                          override the "parameter" named "title" in the json file.'.EOL.'
    ');

if(!isset($flags['f']))
    die('Template file must be selected - option name -f'.EOL);
else
    $fileName = $flags['f'];

$test = isset($flags['t']);

$verbose = isset($flags['v']) || $test;

$newRoot = isset($flags['feroot']) ? $flags['feroot'] : null;

if(isset($flags['extrajson'])){
    $extraJSON = str_replace("'","\"",$flags['extrajson']);
    var_dump($extraJSON,json_decode($extraJSON));
    if(!IOFrame\Util\is_json($extraJSON))
        die('extrajson must be a valid json string!'.EOL);
}
else
    $extraJSON = [];

//Exit if the options file does not exist despite the fact it should
if(!file_exists($jsonUrl.$fileName))
    exit('JSON file does not exist!');

//If the file exists, read it
$FileHandler = new IOFrame\Handlers\FileHandler();
$JSONFile = $FileHandler->readFileWaitMutex($jsonUrl,$fileName,[]);

if(\IOFrame\Util\is_json($JSONFile))
    $config = json_decode($JSONFile,true);
else
    exit('Provided file must be a json!');

$params = [
    'templateRoot'=>$templateUrl,
    'absPathToRoot'=>$settings->getSetting('absPathToRoot'),
    'test'=>$test,
    'verbose'=>$verbose,
    'root'=>$newRoot,
    'extraConfig'=>$extraJSON
];

createPage($config,$params);