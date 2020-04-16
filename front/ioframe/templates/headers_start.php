<html lang="en">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<?php
require __DIR__.'/../../ioframe/templates/ioframe_core_headers.php';

$details = isset($_SESSION['details']) && \IOFrame\Util\is_json($_SESSION['details'])? json_decode($_SESSION['details'],true) : [];

$signedIn = isset($_SESSION['logged_in']) && $_SESSION['logged_in'] == '1';
$active = isset($details['Active']) && $details['Active'] == '1';


$siteConfig = [
    'signedIn'=>$signedIn,
    'active'=>$active,
    'isAdmin'=>$auth->isAuthorized(0)
];

$devMode = $auth->isAuthorized(0) && isset($_REQUEST['devMode']) && $_REQUEST['devMode'];

if($devMode)
    echo '<script src="'.$dirToRoot.'front/ioframe/js/vue/2.6.10/vue.js"></script>';
else
    echo '<script src="'.$dirToRoot.'front/ioframe/js/vue/2.6.10/vue.min.js"></script>';

$JS = ['mixins/commons.js','components/userLogin.js','components/userRegistration.js','components/userLogout.js'];
$CSS = ['global.css','standard.css'];

?>
