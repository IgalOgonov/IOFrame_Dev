<!DOCTYPE html>
<?php

require $settings->getSetting('absPathToRoot').'front/ioframe/templates/definitions.php';

require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot . 'headers_start.php';

require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot . 'cp_redirect_to_login.php';

array_push($CSS, 'cp.css', 'components/searchList.css', 'components/security/securityIPsEditor.css',
    'components/security/securityIPRangesEditor.css','modules/securityIP.css', 'modules/CPMenu.css');
array_push($JS, 'mixins/sourceURL.js', 'mixins/eventHubManager.js', 'components/searchList.js','components/security/securityIPsEditor.js',
    'components/security/securityIPRangesEditor.js','modules/CPMenu.js', 'modules/securityIP.js');


require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot . 'headers_get_resources.php';

echo '<title>(Security) IP</title>';

echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['cp.css']['relativeAddress'] . '"">';
echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['components/searchList.css']['relativeAddress'] . '"">';
echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['components/security/securityIPsEditor.css']['relativeAddress'] . '"">';
echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['components/security/securityIPRangesEditor.css']['relativeAddress'] . '"">';
echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['modules/securityIP.css']['relativeAddress'] . '"">';
echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['modules/CPMenu.css']['relativeAddress'] . '"">';

?>


<?php
$siteConfig = array_merge($siteConfig,
    [
        'page'=> [
            'id' => 'securityIP',
            'title' => '(Security) IP'
        ]
    ]);
?>

<script>
    document.siteConfig = <?php echo json_encode($siteConfig)?>;
    if(document.siteConfig.page.title !== undefined)
        document.title = document.siteConfig.page.title;
</script>

<?php require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot . 'headers_end.php'; ?>

<body>

<div class="wrapper">
<?php require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot.'modules/CPMenu.php';?>
<?php require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot.'modules/securityIP.php';?>

 </div>

</body>


<?php

require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot . 'footers_start.php';

echo '<script src="'.$dirToRoot.$IOFrameJSRoot . $JSResources['mixins/sourceURL.js']['relativeAddress'].'"></script>';
echo '<script src="'.$dirToRoot.$IOFrameJSRoot . $JSResources['mixins/eventHubManager.js']['relativeAddress'].'"></script>';
echo '<script src="'.$dirToRoot.$IOFrameJSRoot . $JSResources['components/searchList.js']['relativeAddress'].'"></script>';
echo '<script src="'.$dirToRoot.$IOFrameJSRoot . $JSResources['components/security/securityIPsEditor.js']['relativeAddress'].'"></script>';
echo '<script src="'.$dirToRoot.$IOFrameJSRoot . $JSResources['components/security/securityIPRangesEditor.js']['relativeAddress'].'"></script>';
echo '<script src="'.$dirToRoot.$IOFrameJSRoot . $JSResources['modules/CPMenu.js']['relativeAddress'].'"></script>';
echo '<script src="'.$dirToRoot.$IOFrameJSRoot . $JSResources['modules/securityIP.js']['relativeAddress'].'"></script>';


require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot . 'footers_end.php';

?>