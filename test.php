<?php


require 'main/coreInit.php';
$dirToRoot = IOFrame\Util\htmlDirDist($_SERVER['REQUEST_URI'],$rootFolder);
echo '<headers>';
echo '<script src="front/ioframe/js/vue/2.6.10/vue.js"></script>';
echo '</headers>';

//Reset DB
/*
require_once 'procedures/SQLdbInit.php';
initDB($settings);
die();
*/
//
echo '<body>';
echo '<div id="test">';

echo '<h1>'.'All Server Side Properties info'.'</h1>';
echo '<button @click = "serverInfo = !serverInfo">Toggle Visibility</button>';
echo '<section :class="{open:serverInfo, closed:!serverInfo}">';
require 'sandbox/serverInfo.php';
echo '</section>';

echo '<h1>'.'Session Info'.'</h1>';
echo '<button @click = "sessionInfo = !sessionInfo">Toggle Visibility</button>';
echo '<section :class="{open:sessionInfo, closed:!sessionInfo}">';
require 'sandbox/sessionInfo.php';
echo '</section>';

echo '<h1>'.'Settings info'.'</h1>';
echo '<button @click = "settingsInfo = !settingsInfo">Toggle Visibility</button>';
echo '<section :class="{open:settingsInfo, closed:!settingsInfo}">';
require 'sandbox/settingsInfo.php';
echo '</section>';

echo '<h1>'.'Settings test'.'</h1>';
echo '<button @click = "settingsTest = !settingsTest">Toggle Visibility</button>';
echo '<section :class="{open:settingsTest, closed:!settingsTest}">';
require 'test/verbose/settingsTest.php';
echo '</section>';

echo '<h1>'.'Tree test'.'</h1>';
echo '<button @click = "treeTest = !treeTest">Toggle Visibility</button>';
echo '<section :class="{open:treeTest, closed:!treeTest}">';
require 'test/verbose/treeTest.php';
echo '</section>';

echo '<h1>'.'User test'.'</h1>';
echo '<button @click = "userTest = !userTest">Toggle Visibility</button>';
echo '<section :class="{open:userTest, closed:!userTest}">';
require 'test/verbose/userTest.php';
echo '</section>';

echo '<h1>'.'Security test'.'</h1>';
echo '<button @click = "securityTest = !securityTest">Toggle Visibility</button>';
echo '<section :class="{open:securityTest, closed:!securityTest}">';
require 'test/verbose/securityTest.php';
echo '</section>';

echo '<h1>'.'Auth test'.'</h1>';
echo '<button @click = "authTest = !authTest">Toggle Visibility</button>';
echo '<section :class="{open:authTest, closed:!authTest}">';
require 'test/verbose/authTest.php';
echo '</section>';

echo '<h1>'.'Parsedown test'.'</h1>';
echo '<button @click = "parsedownTest = !parsedownTest">Toggle Visibility</button>';
echo '<section :class="{open:parsedownTest, closed:!parsedownTest}">';
require 'test/verbose/parsedownTest.php';
echo '</section>';

echo '<h1>'.'Timing Test'.'</h1>';
echo '<button @click = "timingTest = !timingTest">Toggle Visibility</button>';
echo '<section :class="{open:timingTest, closed:!timingTest}">';
require 'test/verbose/timingTest.php';
echo '</section>';

echo '<h1>'.'safeString test'.'</h1>';
echo '<button @click = "safeStringTest = !safeStringTest">Toggle Visibility</button>';
echo '<section :class="{open:safeStringTest, closed:!safeStringTest}">';
require 'test/verbose/safeStringTest.php';
echo '</section>';

echo '<h1>'.'Token test'.'</h1>';
echo '<button @click = "tokenTest = !tokenTest">Toggle Visibility</button>';
echo '<section :class="{open:tokenTest, closed:!tokenTest}">';
require 'test/verbose/tokenTest.php';
echo '</section>';

echo '<h1>'.'logging test'.'</h1>';
echo '<button @click = "loggingTest = !loggingTest">Toggle Visibility</button>';
echo '<section :class="{open:loggingTest, closed:!loggingTest}">';
require 'test/verbose/loggingTest.php';
echo '</section>';

 echo '<h1>'.'Mail test'.'</h1>';
echo '<button @click = "mailTest = !mailTest">Toggle Visibility</button>';
echo '<section :class="{open:mailTest, closed:!mailTest}">';
require 'test/verbose/mailTest.php';
echo '</section>';

/* */
echo '<h1>'.'Plugins test'.'</h1>';
echo '<button @click = "pluginsTest = !pluginsTest">Toggle Visibility</button>';
echo '<section :class="{open:pluginsTest, closed:!pluginsTest}">';
require 'test/verbose/pluginsTest.php';
echo '</section>';

echo '<h1>'.'IP Handler Test'.'</h1>';
echo '<button @click = "IPHandlerTest = !IPHandlerTest">Toggle Visibility</button>';
echo '<section :class="{open:IPHandlerTest, closed:!IPHandlerTest}">';
require 'test/verbose/IPHandlerTest.php';
echo '</section>';

echo '<h1>'.'Objects test'.'</h1>';
echo '<button @click = "objectsTest = !objectsTest">Toggle Visibility</button>';
echo '<section :class="{open:objectsTest, closed:!objectsTest}">';
require 'test/verbose/objectsTest.php';
echo '</section>';

echo '<h1>'.'Order test'.'</h1>';
echo '<button @click = "orderTest = !orderTest">Toggle Visibility</button>';
echo '<section :class="{open:orderTest, closed:!orderTest}">';
require 'test/verbose/orderTest.php';
echo '</section>';

echo '<h1>'.'Routing test'.'</h1>';
echo '<button @click = "routingTest = !routingTest">Toggle Visibility</button>';
echo '<section :class="{open:routingTest, closed:!routingTest}">';
require 'test/verbose/routingTest.php';
echo '</section>';

echo '<h1>'.'Resource test'.'</h1>';
echo '<button @click = "resourceTest = !resourceTest">Toggle Visibility</button>';
echo '<section :class="{open:resourceTest, closed:!resourceTest}">';
require 'test/verbose/resourceTest.php';
echo '</section>';

echo '<h1>'.'Frontend Resource test'.'</h1>';
echo '<button @click = "frontEndResourceTest = !frontEndResourceTest">Toggle Visibility</button>';
echo '<section :class="{open:frontEndResourceTest, closed:!frontEndResourceTest}">';
require 'test/verbose/frontEndResourceTest.php';
echo '</section>';


echo '<h1>'.'Frontend Resources - Media test'.'</h1>';
echo '<button @click = "mediaResourceTest = !mediaResourceTest">Toggle Visibility</button>';
echo '<section :class="{open:mediaResourceTest, closed:!mediaResourceTest}">';
require 'test/verbose/mediaResourceTest.php';
echo '</section>';

echo '<h1>'.'Contacts test'.'</h1>';
echo '<button @click = "contactsTest = !contactsTest">Toggle Visibility</button>';
echo '<section :class="{open:contactsTest, closed:!contactsTest}">';
require 'test/verbose/contactsTest.php';
echo '</section>';

echo '<h1>'.'Orders test'.'</h1>';
echo '<button @click = "ordersTest = !ordersTest">Toggle Visibility</button>';
echo '<section :class="{open:ordersTest, closed:!ordersTest}">';
require 'test/verbose/ordersTest.php';
echo '</section>';

echo '<h1>'.'Templates test'.'</h1>';
echo '<button @click = "templatesTest = !templatesTest">Toggle Visibility</button>';
echo '<section :class="{open:templatesTest, closed:!templatesTest}">';
require 'test/verbose/templatesTest.php';
echo '</section>';

echo '<h1>'.'General sandbox'.'</h1>';
echo '<button @click = "generalSandbox = !generalSandbox">Toggle Visibility</button>';
echo '<section :class="{open:generalSandbox, closed:!generalSandbox}">';
require 'sandbox/generalSandbox.php';
echo '</section>';

echo '<h1>'.'SQL sandbox'.'</h1>';
echo '<button @click = "SQLSandbox = !SQLSandbox">Toggle Visibility</button>';
echo '<section :class="{open:SQLSandbox, closed:!SQLSandbox}">';
require 'sandbox/SQLSandbox.php';
echo '</section>';

echo '<h1>'.'Crypto sandbox'.'</h1>';
echo '<button @click = "cryptoSandbox = !cryptoSandbox">Toggle Visibility</button>';
echo '<section :class="{open:cryptoSandbox, closed:!cryptoSandbox}">';
require 'sandbox/cryptoSandbox.php';
echo '</section>';

echo '<h1>'.'Curl sandbox'.'</h1>';
echo '<button @click = "cURLSandbox = !cURLSandbox">Toggle Visibility</button>';
echo '<section :class="{open:cURLSandbox, closed:!cURLSandbox}">';
require 'sandbox/cURLSandbox.php';
echo '</section>';

echo '<h1>'.'GeoIP sandbox'.'</h1>';
echo '<button @click = "GeoIPSandbox = !GeoIPSandbox">Toggle Visibility</button>';
echo '<section :class="{open:GeoIPSandbox, closed:!GeoIPSandbox}">';
require 'sandbox/GeoIPSandbox.php';
echo '</section>';

echo '</div>';

// --------------- PHP Info
echo '<h1>'.'PHP Info'.'</h1>';
phpinfo();

// --------------- End of body
echo '</body>';


// --------------- Vue script
echo '<script>

    var test = new Vue({
    el: \'#test\',
    data: {
        serverInfo: false,
        sessionInfo: false,
        settingsInfo: false,
        settingsTest: false,
        treeTest: false,
        userTest: false,
        securityTest: false,
        authTest: false,
        parsedownTest: false,
        timingTest: false,
        safeStringTest: false,
        tokenTest: false,
        loggingTest: false,
        mailTest: false,
        pluginsTest: false,
        IPHandlerTest: false,
        objectsTest: false,
        orderTest: false,
        routingTest: false,
        resourceTest: false,
        frontEndResourceTest: false,
        mediaResourceTest: false,
        contactsTest: false,
        ordersTest: false,
        templatesTest: false,
        generalSandbox: false,
        SQLSandbox: false,
        cryptoSandbox: false,
        cURLSandbox: false,
        GeoIPSandbox: false
    }
    });

</script>';

// --------------- CSS
echo '
<style>

section {
    background: rgba(0,0,0,0.1);
    width: calc(100% - 10px);
    margin: auto;
}

section.closed {
    display: none;
}

#test h1 {
    font-size: 150%;
    background: rgb(220,230,240);
}

seperator{
    border: 1px black solid;
    width: 100%;
    display: block;
    margin: 10px 0px;
}
</style>
';

?>