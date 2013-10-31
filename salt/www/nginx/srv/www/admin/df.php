<html>
<head>
<title>Disk Status</title>
</head><body>
<h1>Disk Status</h1>
<pre>
<?php
$output = shell_exec('df -v -h');
echo htmlspecialchars($output);
?>
</pre>
</body>
</html>
