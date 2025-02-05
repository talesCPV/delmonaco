<?php   
	if (IsSet($_POST["path"])){
        $path = getcwd().$_POST["path"];
        if (file_exists($path)) {
            unlink($path);
        }
    }        
    
?>