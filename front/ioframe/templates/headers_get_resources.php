<?php

$JSOptions = ['rootFolder'=>$IOFrameJSRoot,'forceMinify'=>(!$devMode)];
$CSSOptions = ['rootFolder'=>$IOFrameCSSRoot,'forceMinify'=>(!$devMode)];

//Some defaults
if(!isset($minifyOptions))
    $minifyOptions = [];
if(!isset($minifyOptions['js']))
    $minifyOptions['js'] = null;
if(!isset($minifyOptions['css']))
    $minifyOptions['css'] = null;

//Defined to be by frontEndResourceTemplateManager later - can also changed if we minify resources into a single file
$JSOrder = $JS;
$CSSOrder = $CSS;

foreach(['js','css'] as $resourceType){
    if($minifyOptions[$resourceType] && is_array($minifyOptions[$resourceType])){
        //Minified file name
        if($minifyOptions[$resourceType]['name']){
            if($resourceType === 'js'){
                $JSOptions['minifyName'] = $minifyOptions[$resourceType]['name'];
                $JSOrder = [$JSOptions['minifyName']];
            }
            else{
                $CSSOptions['minifyName'] = $minifyOptions[$resourceType]['name'];
                $CSSOrder = [$CSSOptions['minifyName']];
            }

            //Minified file folder - defaults to 'min'
            if($minifyOptions[$resourceType]['folder']){
                if($resourceType === 'js')
                    $JSOptions['minifyToFolder'] = $minifyOptions[$resourceType]['folder'];
                else
                    $CSSOptions['minifyToFolder'] = $minifyOptions[$resourceType]['folder'];
            }
            else{
                if($resourceType === 'js')
                    $JSOptions['minifyToFolder'] = 'min';
                else
                    $CSSOptions['minifyToFolder'] = 'min';
            }
        }
    }
}

$JSResources = $FrontEndResourceHandler->getJS($JS,$JSOptions);
$CSSResources = $FrontEndResourceHandler->getCSS($CSS,$CSSOptions);

if(!defined('frontEndResourceTemplateManager'))
    require $rootFolder.'IOFrame/Util/frontEndResourceTemplateManager.php';

$frontEndResourceTemplateManager = new IOFrame\Util\frontEndResourceTemplateManager(
    [
        'JSResources' => $JSResources,
        'CSSResources' => $CSSResources,
        'JSOrder' => $JSOrder,
        'CSSOrder' => $CSSOrder,
        'dirToRoot' => $dirToRoot,
        'JSResourceRoot' => $IOFrameJSRoot,
        'CSSResourceRoot' => $IOFrameCSSRoot
    ]
);