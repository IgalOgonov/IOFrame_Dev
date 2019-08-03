<?php

include_once __DIR__.'/../../IOFrame/Handlers/ext/parsedown/Parsedown.php';
echo '
<form name="form" method="post">
<div style="position: inherit; bottom: 64px; top: 64px;">
    <textarea name="markdown">Welcome to the demo:

1. Write Markdown text here
2. Hit the __Parse__ button
3. See the result bellow

Test!
    Test!!

    TEST!!!

    Oh look some code!</textarea>
    </div>
    <div style="position: inherit; bottom: 0; width: 30%;">
        <div style="position: inherit;">
            <button type="submit">Parse</button>
        </div>
    </div>
</form>
';
$parser = new Parsedown();
if(isset($_REQUEST["markdown"])){
    $parsedownText = $parser->text($_REQUEST["markdown"]).EOL;
    echo $parsedownText;
}