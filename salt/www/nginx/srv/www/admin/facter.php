<html>
<head>
<title>Facter></title>
</head><body>
<h1>Facter></h1>
<pre>
<?php
$output = shell_exec('facter');
echo htmlspecialchars($output);
?>
</pre>
</body>
</html>
