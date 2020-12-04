<script>
    let canAccessCP = <?php echo (($auth->isAuthorized(0) || $auth->hasAction('CAN_ACCESS_CP')) ? 'true' : 'false')?>;
    if( (location.pathname !== document.rootURI + 'cp/account') && ((!document.loggedIn && !localStorage.getItem('sesID')) || (document.loggedIn && !canAccessCP)) )
            location = document.rootURI + 'cp/login';

<?php
/*This checks whether there is a possible system update, and whether the user is authorized to update*/
if(!isset($FileHandler))
    $FileHandler = new IOFrame\Handlers\FileHandler();
$availableVersion = $FileHandler->readFile($rootFolder.'/meta/', 'ver');
$currentVersion = $siteSettings->getSetting('ver');
if($availableVersion && $currentVersion && ($currentVersion !== $availableVersion) && ($auth->isAuthorized(0) || $auth->hasAction('CAN_UPDATE_SYSTEM'))){
    $versions = [
        'currentVersion'=>$currentVersion,
        'availableVersion'=>$availableVersion
    ];
    echo 'document["_ioframe"] = '.json_encode($versions);
}
unset($availableVersion,$currentVersion,$versions);
?>

</script>
