
<?php

$dirToRoot = IOFrame\Util\htmlDirDist($_SERVER['REQUEST_URI'],$settings->getSetting('pathToRoot'));
$currentPage = substr($_SERVER['PHP_SELF'],strlen($settings->getSetting('pathToRoot')));
$currentPageURI = substr($_SERVER['REQUEST_URI'],strlen($settings->getSetting('pathToRoot')));
$rootURI = $settings->getSetting('pathToRoot');
if(!defined($IOFrameCSSRoot) || !defined($IOFrameJSRoot))
    require_once 'definitions.php';

/* -- Initiate resource handler and get core JS files and the CSS file--*/
if(!isset($FrontEndResourceHandler))
    $FrontEndResourceHandler = new IOFrame\Handlers\FrontEndResourceHandler($settings,$defaultSettingsParams);
$coreJS = $FrontEndResourceHandler->getJSCollection( 'IOFrameCoreJS',['rootFolder'=>$IOFrameJSRoot]);
echo '<script src=\''.$dirToRoot.$IOFrameJSRoot.$coreJS['relativeAddress'].'\'></script>';
$ezAlertCSS = $FrontEndResourceHandler->getCSS(['ezAlert.css'],['rootFolder'=>$IOFrameCSSRoot])['ezAlert.css'];
echo '<link rel="stylesheet" href=\''.$dirToRoot.$IOFrameCSSRoot.$ezAlertCSS['relativeAddress'].'\'>';

/*Include plugins JS files, if those exist*/
$jsIncludes = $orderedPlugins;
if(is_dir($settings->getSetting('absPathToRoot').'front/ioframe/js/plugins')){
    $dirArray = scandir($settings->getSetting('absPathToRoot').'front/ioframe/js/plugins');
    foreach($jsIncludes as $key => $val){
        $jsIncludes[$key] .= '.js';
        $jsInclude = $settings->getSetting('absPathToRoot').'front/ioframe/js/plugins/'.$jsIncludes[$key];
        if(file_exists($jsInclude))
            echo '<script src=\''.$dirToRoot.'front/ioframe/js/plugins/'.$jsIncludes[$key].'\'></script>';
    }
    foreach($dirArray as $key => $fileName){
        if(preg_match('/^[a-zA-Z0-9_-]+\.js$/',$fileName) && !in_array($fileName,$jsIncludes)){
            echo '<script src=\''.$dirToRoot.'front/ioframe/js/plugins/'.$fileName.'\'></script>';
        }
    }
}

/*Get the languages and parse them*/
$languages = $siteSettings->getSetting('languages');
if(!empty($languages))
    $languages = explode(',',$languages);
else
    $languages = [];
?>

<script>
    //This is the path to the root of the IOFrame site
    document.pathToRoot = '<?php echo $dirToRoot;?>';
    //Site Name
    document.siteName = encodeURI('<?php echo $siteSettings->getSetting('siteName');?>');
    //Current page full name
    document.currentPage = encodeURI('<?php echo $currentPage;?>');
    //Current page URI
    document.currentPageURI = encodeURI('<?php echo $currentPageURI;?>');
    //Current page URI
    document.imagePathLocal = encodeURI('<?php echo $resourceSettings->getSetting('imagePathLocal');?>');
    //Current page URI
    document.videoPathLocal = encodeURI('<?php echo $resourceSettings->getSetting('videoPathLocal');?>');
    //Current page URI
    document.jsPathLocal = encodeURI('<?php echo $resourceSettings->getSetting('jsPathLocal');?>');
    //Current page URI
    document.cssPathLocal = encodeURI('<?php echo $resourceSettings->getSetting('cssPathLocal');?>');
    //Current root URI
    document.rootURI = encodeURI('<?php echo $rootURI;?>');
    //Path to the current page from root
    document.loggedIn = <?php echo $auth->isLoggedIn()? "true" : "false";  ?>;
    //Difference between local time and server time - in seconds!
    document.serverTimeDelta = Math.floor( Math.floor(Date.now()/1000 - <?php echo time();?>) / 10) * 10;
    //Languages
    document.languages = <?php echo json_encode($languages);?>;
    //CSRF Token
    if(localStorage)
        localStorage.setItem('CSRF_token','<?php echo $_SESSION['CSRF_token'];?>');
    //In a very specific case PHP has re-logged using cookies and the session ID changed - this will only work if the relog happaned on a page with this script
    let newID = <?php echo isset($newID) ? "'".$newID."'" : 'false';?>;
    if(newID && localStorage)
        localStorage.setItem('sesID',newID);
    //Retrieve selected language from localStorage if one exists - can be null
    document.selectedLanguage = localStorage.getItem('lang');

    document.addEventListener('DOMContentLoaded', function(e) {
        //Define callbacks if not defined
        if(document.callbacks === undefined)
            document.callbacks = {};
        //Initiate the page
        initPage(document.pathToRoot, document.callbacks);
    }, true);

</script>