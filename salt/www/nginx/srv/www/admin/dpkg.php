<html>
<head>
<title>Packages</title>
</head><body>
<h1>Packages</h1>
<pre>
<?php
$output = shell_exec('dpkg --get-selections');
echo htmlspecialchars($output);
?>
</pre>
</body>
</html>
