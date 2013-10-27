<html><head>
<title>Admin</title>
<link rel="shortcut icon" href="/favicon.ico">
</head><body>
<h2>Admin functions</h2>
<ul>
<?php
$d = dir("/etc/nginx/admin.d");
while (false !== ($entry = $d->read())) {
     #echo "<li>Found: " . $entry;
     if (preg_match("/(.*).conf/", $entry, $matches)) {
         echo '<li><a href="/' . $matches[1] . '/">' . $matches[1] . "</a>\n";
     }
}
$d->close();
?>
<li><a href="phpinfo.php">phpinfo</a>
</ul>

<h2>localhost port mapping</h2>

<ul>
{%- for port, host_port in pillar['mapped_ports'].items() %}
<li>
  {%- if port == 22 %}
    <i>ssh localhost -p {{ host_port }}</i> mapped to ssh port {{ port }}
  {%- else %}
    {%- if (port == 443) or (port == 880 and pillar['admin_password']) %}
      <a href="https://localhost:{{ host_port }}/">https://localhost:{{ host_port }}/</a> -
    {%- else %}
      <a href="http://localhost:{{ host_port }}/">http://localhost:{{ host_port }}/</a> -
    {%- endif %}
    {%- if port == 80 %}
      main site (production via cap deploy)
    {%- elif port == 443 %}
      main secure site (production via cap deploy)
    {%- elif port == 880 %}
      this admin site
    {%- elif port == 3000 %}
      rails app (development mode)
    {%- else %}
      other app
    {%- endif %}
    {%- if (port == 443) or (port == 880 and pillar['admin_password']) %}
      on port <a href="https://localhost:{{ port }}">{{ port }}</a>
    {%- else %}
      on port <a href="http://localhost:{{ port }}">{{ port }}</a>
    {%- endif %}
  {%- endif %}
{%- endfor %}
</ul>

<h2>Roles</h2>
<ul>
{%- for role in pillar['roles'] %}
<li>{{ role }}
{%- endfor %}
</ul>

<h2>Versions</h2>
<ul>
{%- for app in pillar['versions'] %}
<li>{{ app }}: {{ pillar['versions'][app] }}
{%- endfor %}
</ul>

</body></html>
