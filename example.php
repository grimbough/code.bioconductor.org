<html>
<head>
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.21/css/jquery.dataTables.css">
    <link rel="stylesheet" type="text/css" href="/css/styles.css">
    <link rel="stylesheet" type="text/css" href="/css/gitlist.css">
    <link rel="stylesheet" href="/gitlist/prod/css/bootstrap-cosmo.198b7680e107dcbb25cc3cda8618580c9cf1d07ecc6e4d4747522e834d851d0c.css" id="bootstrap-theme">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.21/js/jquery.dataTables.js"></script>
    <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.14.0/css/all.min.css">
    
</head>
<body>

<?php
try {
    // Connect to the SQLite Database.
    $myPDO = new PDO('sqlite:/tmp/packages.db');
} catch(Exception $e) {
    die('connection_unsuccessful: ' . $e->getMessage());
}
?>


<div class="navbar navbar-default navbar-fixed-top" id="p3x-gitlist-navigation" role="navigation">
    <div class="container">
        <div class="navbar-header p3x-gitlist-navbar-header">
            <button type="button" id="p3x-gitlist-navigation-menu-button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>

            <a href="/gitlist/">
                <img src="/gitlist/img/gitlist.svg" class="hidden-xs" id="p3x-gitlist-navigation-brand-icon">
                <img src="/gitlist/img/gitlist.svg" class="visible-xs p3x-gitlist-navigation-brand-icon-small" id="p3x-gitlist-navigation-brand-icon" data-toggle="tooltip" data-placement="bottom" title="" data-original-title="Unofficial Bioconductor Git Browser">
            </a>
            <a class="navbar-brand hidden-xs" href="/gitlist/">
                Unofficial Bioconductor Git Browser
            </a>

        </div>
    </div>
</div>

<div class="p3x-gitlist-header-height"></div>

<div class="wrapper">

<table id="table_id" class="display">

<thead>
<tr>
<td>Package Name</td><td>Latest Commit</td>
</tr>
</thead>

<tbody>
<?php

$stm = $myPDO->query("SELECT * FROM packages");
$rows = $stm->fetchAll(PDO::FETCH_NUM);

foreach($rows as $row) {

    printf("<tr><td><i class='fas fa-folder'></i>&nbsp;<a href=\"/gitlist/$row[0]\">$row[0]</a></td>");
    printf("<td>$row[2] by $row[1] to $row[3]</td></tr>\n");
}
?>
</tbody>
</table>

<script>
$(document).ready( function () {
    $('#table_id').DataTable( {
        "pageLength": 25
    });
} );
</script>

<div> 
</body>
</html>
