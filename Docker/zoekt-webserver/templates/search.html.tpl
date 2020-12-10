
<html>
{{template "head"}}
<title>BioC Code Search</title>
<body>
  <div class="jumbotron">
    <div class="container">
      {{template "searchbox" .Last}}
    </div>
  </div>

  <div class="container">
    <div class="row">
      <div class="col-md-8">
        <h3>Search examples:</h3>
        <dl class="dl-horizontal">
          <dt><a href="search?q=needle">needle</a></dt><dd>search for "needle"</dd>
          <dt><a href="search?q=thread+or+needle">thread or needle</a></dt><dd>search for either "thread" or "needle"</dd>
          <dt><a href="search?q=class+needle">class needle</a></span></dt><dd>search for files containing both "class" and "needle"</dd>
          <dt><a href="search?q=class+Needle">class Needle</a></dt><dd>search for files containing both "class" (case insensitive) and "Needle" (case sensitive)</dd>
          <dt><a href="search?q=class+Needle+case:yes">class Needle case:yes</a></dt><dd>search for files containing "class" and "Needle", both case sensitively</dd>
          <dt><a href="search?q=%22class Needle%22">"class Needle"</a></dt><dd>search for files with the phrase "class Needle"</dd>
          <dt><a href="search?q=needle+-hay">needle -hay</a></dt><dd>search for files with the word "needle" but not the word "hay"</dd>
          <dt><a href="search?q=path+file:java">path file:java</a></dt><dd>search for the word "path" in files whose name contains "java"</dd>
          <dt><a href="search?q=needle+lang%3Apython&num=50">needle lang:python</a></dt><dd>search for "needle" in Python source code</dd>
          <dt><a href="search?q=f:%5C.R%24">f:\.R$</a></dt><dd>search for files whose name ends with ".R"</dd>
          <dt><a href="search?q=path+-file:java">path -file:java</a></dt><dd>search for the word "path" excluding files whose name contains "java"</dd>
          <dt><a href="search?q=foo.*bar">foo.*bar</a></dt><dd>search for the regular expression "foo.*bar"</dd>
          <dt><a href="search?q=-%28Path File%29 Stream">-(Path File) Stream</a></dt><dd>search "Stream", but exclude files containing both "Path" and "File"</dd>
          <dt><a href="search?q=-Path%5c+file+Stream">-Path\ file Stream</a></dt><dd>search "Stream", but exclude files containing "Path File"</dd>
          <!--<dt><a href="search?q=sym:data">sym:data</a></span></dt><dd>search for symbol definitions containing "data"</dd>-->
          <dt><a href="search?q=phone+r:droid">phone r:droid</a></dt><dd>search for "phone" in repositories whose name contains "droid"</dd>
          <!--<dt><a href="search?q=phone+b:master">phone b:master</a></dt><dd>for Git repos, find "phone" in files in branches whose name contains "master".</dd>
          <dt><a href="search?q=phone+b:HEAD">phone b:HEAD</a></dt><dd>for Git repos, find "phone" in the default ('HEAD') branch.</dd>-->
        </dl>
      </div>
      <div class="col-md-4">
        <h3>To list repositories, try:</h3>
        <dl class="dl-horizontal">
          <dt><a href="search?q=r:Affy">r:Affy</a></dt><dd>list packages whose name contains "Affy".</dd>
          <dt><a href="search?q=r:Affy+-r:Data">r:Affy -r:Data</a></dt><dd>list packages whose name contains "Affy" but not "Data".</dd>
        </dl>
      </div>
    </div>
  </div>
  <nav class="navbar navbar-default navbar-bottom">
    <div class="container">
      {{template "footerBoilerplate"}}
      <p class="navbar-text navbar-right">
        Used {{HumanUnit .Stats.IndexBytes}} mem for
        {{.Stats.Documents}} documents ({{HumanUnit .Stats.ContentBytes}})
        from {{.Stats.Repos}} repositories.
      </p>
    </div>
  </nav>
</body>
</html>
