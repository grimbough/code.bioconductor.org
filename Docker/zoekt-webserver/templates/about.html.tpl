

<html>
  {{template "head"}}
  <title>About <em>zoekt</em></title>
<body>


  <div class="jumbotron">
    <div class="container">
      {{template "searchbox" .Last}}
    </div>
  </div>

  <div class="container">
    <p>
      This is <a href="http://github.com/google/zoekt"><em>zoekt</em> (IPA: /zukt/)</a>,
      an open-source full text search engine. It's pronounced roughly as you would
      pronounce "zooked" in English.
    </p>
    <p>
    {{if .Version}}<em>Zoekt</em> version {{.Version}}, uptime{{else}}Uptime{{end}} {{.Uptime}}
    </p>

    <p>
    Used {{HumanUnit .Stats.IndexBytes}} memory for
    {{.Stats.Documents}} documents ({{HumanUnit .Stats.ContentBytes}})
    from {{.Stats.Repos}} repositories.
    </p>
  </div>

  <nav class="navbar navbar-default navbar-bottom">
    <div class="container">
      {{template "footerBoilerplate"}}
      <p class="navbar-text navbar-right">
      </p>
    </div>
  </nav>
