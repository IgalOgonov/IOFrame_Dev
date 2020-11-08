<!DOCTYPE html>
<?php

require $settings->getSetting('absPathToRoot').'front/ioframe/templates/definitions.php';

require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot.'headers_start.php';

require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot . 'cp_redirect_to_login.php';

array_push($JS,'mixins/sourceUrl.js','mixins/eventHubManager.js','components/searchList.js','components/media/mediaViewer.js',
    'components/gallery/galleryEditor.js','modules/CPMenu.js','modules/galleries.js');

array_push($CSS,'animations.css','cp.css','components/searchList.css','components/media/mediaViewer.css',
    'components/galleries/galleryEditor.css','modules/CPMenu.css','modules/galleries.css');

require $settings->getSetting('absPathToRoot') . $IOFrameTemplateRoot.'headers_get_resources.php';

echo '<title>Galleries</title>';

$frontEndResourceTemplateManager->printResources('CSS');
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

<?php

require $settings->getSetting('absPathToRoot') . $IOFrameTemplateRoot.'footers_start.php';

$frontEndResourceTemplateManager->printResources('JS');

require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot.'footers_end.php';

?>