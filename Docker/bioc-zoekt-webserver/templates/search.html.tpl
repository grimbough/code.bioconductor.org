
<html>
{{template "head"}}
<title>Bioconductor Code Search</title>
<body>

  <div class="navbar navbar-default navbar-static-top py-0" role="navigation">
    <div class="container">
      <div class="navbar-header">
        <a class="navbar-brand" href="/">
          <img class="brand-square" src="https://www.huber.embl.de/users/msmith/bioconductor_code_square.png" alt="Bioconductor Code Logo" title="Bioconductor Code Tools">
        </a>
      </div>
      <ul class="nav navbar-nav navbar-right">
        <li><a href="/about.html">About</a></li>
      </ul>
    </div>
  </div>

  <main role="main">

    <div class="jumbotron">
      <div class="container">
        <div class="row">
          <div class="col-md-12 text-center">
            <h3>Search across all Bioconductor software packages</h3>
          </div>
        </div>
        {{template "searchbox" .Last}}
      </div>
    </div>

    {{template "searchExamples"}}
    
  </main>
  <footer class="footer">
    <div class="container">
      <div class="row pt-3">
        <div class="col-sm-6">
          {{template "footerBoilerplate"}}
        </div>
        <div class="col-sm-6 text-right">
          <p>
            Used {{HumanUnit .Stats.IndexBytes}} mem for
            {{.Stats.Documents}} documents ({{HumanUnit .Stats.ContentBytes}})
            from {{.Stats.Repos}} repositories.
          </p>
        </div>
      </div>
    </div>
  </footer>
</body>
</html>
