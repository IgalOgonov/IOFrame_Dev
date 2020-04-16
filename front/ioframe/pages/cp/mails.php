<!DOCTYPE html>
<?php

require $settings->getSetting('absPathToRoot').'front/ioframe/templates/definitions.php';

require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot.'headers_start.php';

array_push($JS,'modules/CPMenu.js','modules/mails.js');

array_push($CSS,'cp.css','modules/CPMenu.css','modules/mails.css');

require $settings->getSetting('absPathToRoot') . $IOFrameTemplateRoot.'/headers_get_resources.php';

echo '<title>Mails</title>';

echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['cp.css']['relativeAddress'] . '"">';
echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['modules/CPMenu.css']['relativeAddress'] . '"">';
echo '<link rel="stylesheet" href="' . $dirToRoot . $IOFrameCSSRoot . $CSSResources['modules/mails.css']['relativeAddress'] . '"">';
?>

<?php
$siteConfig = array_merge($siteConfig,
    [
        'page'=> [
            'id' => 'mails',
            'title' => 'Mails'
        ]
    ]);
?>

<script>
    document.siteConfig = <?php echo json_encode($siteConfig)?>;
    if(document.siteConfig.page.title !== undefined)
        document.title = document.siteConfig.page.title;
</script>


<?php require $settings->getSetting('absPathToRoot') . $IOFrameTemplateRoot.'/headers_end.php'; ?>

<body>

<div class="wrapper">
    <?php require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot.'/modules/CPMenu.php';?>
    <?php require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot.'/modules/mails.php';?>
</div>

</body>

<?php require $settings->getSetting('absPathToRoot') . $IOFrameTemplateRoot.'/footers_start.php'; ?>


<?php
echo '<script src=\''.$dirToRoot.$IOFrameJSRoot.$JSResources['modules/CPMenu.js']['relativeAddress'].'\'></script>';
echo '<script src=\''.$dirToRoot.$IOFrameJSRoot.$JSResources['modules/mails.js']['relativeAddress'].'\'></script>';

?>

<?php require $settings->getSetting('absPathToRoot').$IOFrameTemplateRoot.'/footers_end.php';?>