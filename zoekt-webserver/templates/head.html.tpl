
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Search source code across all Bioconductor packages">
    <meta name="keywords" content="Bioconductor, Code, Git, Search, R, Packages">
    
    <title>Bioconductor Code Search</title>

    <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
    <link rel="manifest" href="/site.webmanifest">
    <link rel="mask-icon" href="/safari-pinned-tab.svg" color="#3792ad">
    <meta name="msapplication-TileColor" content="#3792ad">
    <meta name="theme-color" content="#1a81c2">

    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">
    <link href="https://fonts.googleapis.com/css2?family=Lato&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" integrity="sha512-iBBXm8fW90+nuLcSKlbmrPcLa0OT92xO1BIsZ+ywDWZCvqsWgccV3gFoRBv0z+8dLJgyAHIhR35VZc2oM/gI1w==" crossorigin="anonymous" />

    <meta property="og:url" content="https://code.bioconductor.org/search">
    <meta property="og:type" content="website">
    <meta property="og:title" content="Bioconductor Code: Search">
    <meta property="og:description" content="Search source code across all Bioconductor packages">
    <meta property="og:image" content="https://code.bioconductor.org/images/bioc_code_search_og.png">

    <meta name="twitter:card" content="summary">
    <meta name="twitter:title" content="Bioconductor Code: Search">
    <meta name="twitter:site" content="@Bioconductor">
    <meta name="twitter:image" content="https://code.bioconductor.org/images/bioc_code_search_square_blue.png">
    <meta name="twitter:image:all" content="Logo for Bioconductor code search website.">

    <!-- matomo used for visitor counting; required to justify de.NBI funding -->
    <script type="text/javascript">
        var _paq = window._paq = window._paq || [];
        /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
        _paq.push(['trackPageView']);
        _paq.push(['enableLinkTracking']);
        (function() {
            var u="https://tr-denbi.embl.de/heimdall/";
            _paq.push(['setTrackerUrl', u+'p.php']);
            _paq.push(['setSiteId', '37']);
            var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
            g.type='text/javascript'; g.async=true; g.src=u+'p.js'; s.parentNode.insertBefore(g,s);
        })(); 
    </script>

<style>

  body {
    font-family: "Lato", Helvetica, Arial, sans-serif;
    font-size: 13px;
    line-height: 1.42857143;
    color: #333333;
    background-color: #fff;
  }

  .label-dup {
    border-width: 1px !important;
    border-style: solid !important;
    border-color: #aaa !important;
    color: black;
  }
  .noselect {
    user-select: none;
  }
  a.label-dup:hover {
    color: black;
    background: #ddd;
  }
  .result {
    display: block;
    content: " ";
    visibility: hidden;
  }
  .inline-pre {
     border: unset;
     background-color: unset;
     margin: unset;
     padding: unset;
     overflow: unset;
  }
  :target { background-color: #ccf; }
  table tbody tr td { border: none !important; padding: 2px !important; }

  .btn-primary {
      background-color: #1a81c2;
      border-color: #1a81c2;
  }

  .btn-success {
    color: #fff;
    background-color: #87b13f;
    border-color: #87b13f;
  }

  .jumbotron {
    padding-top: 35px;
    padding-bottom: 35px;
  }

  .navbar {
    background-color: #1a81c2;
  }

  .navbar li a {
    color: white;
  }

  .brand-square {
    height: 40px;
  }

  .navbar-centre-img {
    height: 30px;
    margin-top: 7px;
  }

  .navbar-brand-centre {
    transform: translateX(-50%);
    left: 50%;
    position: absolute;
  }

  .navbar-right a {
    color: #fff;
  }

  a {
    color: #1a81c2;
  }

  .footer {
    background-color: #e9ecef;
    bottom: 0;
    width: 100%;
  }

  .result-table {
    overflow-x: auto;
  }

  .result-table tbody tr:nth-child(odd) {
    background-color: #f2f2f2;
  }

</style>
</head>
  