<?php
/*This file needs to restore the test include based on where the update failed, if at all.*/
$existingInclude = $this->FileHandler->readFileWaitMutex($url,'include.php',[]);
if(!$existingInclude)
    throw new \Exception("Failed to read existing include!");
if($verbose)
    echo 'Existing include is '.htmlspecialchars($existingInclude).', Cur version: '.$currentVersion.', Target version: '.$targetVersion.EOL;

//Based on the version, we decide on whether adding new initiation commands or modifying old ones.
//Remember that the disk write did not necessarily go through
if($currentVersion === 1){
    if(strpos($existingInclude,'$_SESSION[\'currentVersion\']') !== false)
        $existingInclude = str_replace('$_SESSION[\'currentVersion\'] = '.$targetVersion.';'.EOL_FILE.
            '?>','?>',$existingInclude);
}
else{
    if(strpos($existingInclude,'$_SESSION[\'currentVersion\'] = '.$targetVersion) !== false)
        $existingInclude = str_replace('$_SESSION[\'currentVersion\'] = '.$targetVersion,'
        $_SESSION[\'currentVersion\'] = '.$currentVersion.';',$existingInclude);
}

//Write overwrite the old include, if not testing.
if($verbose){
    echo 'Restored include is '.htmlspecialchars($existingInclude).EOL;
}
if(!$test){
    if(!$this->FileHandler->writeFileWaitMutex($url,'include.php',$existingInclude,$params))
        throw new \Exception("Failed to write restored include!");
}
?>