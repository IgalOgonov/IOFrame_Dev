<!DOCTYPE html>
<?php

require $settings->getSetting('absPathToRoot').'front/ioframe/templates/definitions.php';

require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot.'headers_start.php';

require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot . 'cp_redirect_to_login.php';

array_push($JS,'mixins/sourceURL.js','mixins/eventHubManager.js','components/searchList.js','components/media/mediaViewer.js',
    'components/gallery/galleryEditor.js','modules/CPMenu.js','modules/galleries.js');

array_push($CSS,'animations.css','cp.css','components/searchList.css','components/media/mediaViewer.css',
    'components/galleries/galleryEditor.css','modules/CPMenu.css','modules/galleries.css');

require $settings->getSetting('absPathToRoot') . $IOFrameTemplateRoot.'headers_get_resources.php';

echo '<title>Galleries</title>';

echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['cp.css']['relativeAddress'] . '"">';
echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['animations.css']['relativeAddress'] . '"">';
echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['modules/CPMenu.css']['relativeAddress'] . '"">';
echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['modules/galleries.css']['relativeAddress'] . '"">';
echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['components/searchList.css']['relativeAddress'] . '"">';
echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['components/media/mediaViewer.css']['relativeAddress'] . '"">';
echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['components/galleries/galleryEditor.css']['relativeAddress'] . '"">';
?>


<?php
$siteConfig = array_merge($siteConfig,
    [
        'page'=> [
            'id' => 'galleries',
            'title' => 'Galleries'
        ]
    ]);
?>

<script>
    document.siteConfig = <?php echo json_encode($siteConfig)?>;
    if(document.siteConfig.page.title !== undefined)
        document.title = document.siteConfig.page.title;
</script>

<?php require $settings->getSetting('absPathToRoot') . $IOFrameTemplateRoot.'headers_end.php'; ?>

<body>

<div class="wrapper">
    <?php require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot.'modules/CPMenu.php';?>
    <?php require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot.'modules/galleries.php';?>
</div>

</body>

<?php require $settings->getSetting('absPathToRoot') . $IOFrameTemplateRoot.'footers_start.php'; ?>


<?php
echo '<script src="'.$dirToRoot.$IOFrameJSRoot.$JSResources['mixins/sourceURL.js']['relativeAddress'].'"></script>';
echo '<script src="'.$dirToRoot.$IOFrameJSRoot.$JSResources['mixins/eventHubManager.js']['relativeAddress'].'"></script>';
echo '<script src="'.$dirToRoot.$IOFrameJSRoot.$JSResources['components/searchList.js']['relativeAddress'].'"></script>';
echo '<script src="'.$dirToRoot.$IOFrameJSRoot.$JSResources['components/media/mediaViewer.js']['relativeAddress'].'"></script>';
echo '<script src="'.$dirToRoot.$IOFrameJSRoot.$JSResources['components/gallery/galleryEditor.js']['relativeAddress'].'"></script>';
echo '<script src="'.$dirToRoot.$IOFrameJSRoot.$JSResources['modules/CPMenu.js']['relativeAddress'].'"></script>';
echo '<script src="'.$dirToRoot.$IOFrameJSRoot.$JSResources['modules/galleries.js']['relativeAddress'].'"></script>';
?>

<?php require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot.'footers_end.php';?>