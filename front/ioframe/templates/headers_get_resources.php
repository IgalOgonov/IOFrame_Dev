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

foreach(['js','css'] as $resourceType){
    if($minifyOptions[$resourceType] && is_array($minifyOptions[$resourceType])){
        //Minified file name
        if($minifyOptions[$resourceType]['name']){
            if($resourceType === 'js')
                $JSOptions['minifyName'] = $minifyOptions[$resourceType]['name'];
            else
                $CSSOptions['minifyName'] = $minifyOptions[$resourceType]['name'];

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
