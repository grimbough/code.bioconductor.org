
<html>
{{template "head"}}
<title>Results for {{.QueryStr}}</title>
<script>
  function zoektAddQ(atom) {
    window.location.href = "/search?q=" + escape("{{.QueryStr}}" + " " + atom) +
    "&" + "num=" + {{.Last.Num}};
  }
</script>
<body id="results">
  {{template "navbar" .Last}}

  <main role="main">

    <div class="container">
      <h5>
        {{if .Stats.Crashes}}<br><b>{{.Stats.Crashes}} shards crashed</b><br>{{end}}
        {{ $fileCount := len .FileMatches }}
        Found {{.Stats.MatchCount}} results in {{.Stats.FileCount}} files{{if or (lt $fileCount .Stats.FileCount) (or (gt .Stats.ShardsSkipped 0) (gt .Stats.FilesSkipped 0)) }},
        showing top {{ $fileCount }} files (<a rel="nofollow"
        href="search?q={{.Last.Query}}&num={{More .Last.Num}}">show more</a>).
        {{else}}.{{end}}
      </h5>
      {{range $FM := .FileMatches}}
      <div class="container-fluid result-table px-0">
      <table class="table table-hover table-condensed">
        <thead>
          <tr>
            <th>
              <a href="/browse/{{$FM.Repo}}/blob/devel/{{$FM.FileName}}">
              <!--{{if .URL}}<a name="{{.ResultID}}" class="result"></a><a href="{{.URL}}" >{{else}}<a name="{{.ResultID}}">{{end}}-->
                <small>
                {{$FM.Repo}}:{{$FM.FileName}}</a>:
                <span style="font-weight: normal">[ {{if $FM.Branches}}{{range $FM.Branches}}<span class="label label-default">{{.}}</span>,{{end}}{{end}} ]</span>
                {{if $FM.Language}}<button
                title="restrict search to files written in {{.Language}}"
                onclick="zoektAddQ('lang:{{.Language}}')" class="label label-primary">language {{$FM.Language}}</button></span>{{end}}
                {{if $FM.DuplicateID}}<a class="label label-dup" href="#{{.DuplicateID}}">Duplicate result</a>{{end}}
              </small>
            </th>
          </tr>
        </thead>
        {{if not $FM.DuplicateID}}
        <tbody>
          {{range $M := $FM.Matches}}
          <tr>
            <td>
              <pre class="inline-pre"><span class="noselect"><a href="/browse/{{$FM.Repo}}/blob/devel/{{$FM.FileName}}#L{{$M.LineNum}}"><u>{{$M.LineNum}}</u></a></span>: {{range .Fragments}}{{LimitPre 100 .Pre}}<b>{{.Match}}</b>{{LimitPost 100 .Post}}{{end}}</pre>
            </td>
          </tr>
          {{end}}
        </tbody>
        {{end}}
      </table>
      </div>
      {{end}}
    </div>

  </main>

  <footer class="footer">
    <div class="container">
      <div class="row pt-3">
        <div class="col-sm-6">
          {{template "footerBoilerplate"}}
        </div>
        <div class="col-sm-6 text-right">
          <p>
            Took {{.Stats.Duration}}{{if .Stats.Wait}}(queued: {{.Stats.Wait}}){{end}} for
            {{HumanUnit .Stats.IndexBytesLoaded}}B index data,
            {{.Stats.NgramMatches}} ngram matches, <br>
            {{.Stats.FilesConsidered}} docs considered,
            {{.Stats.FilesLoaded}} docs ({{HumanUnit .Stats.ContentBytesLoaded}}B)
            loaded{{if or .Stats.FilesSkipped .Stats.ShardsSkipped}},
            {{.Stats.FilesSkipped}} docs and {{.Stats.ShardsSkipped}} shards skipped{{else}}.{{end}}
          </p>
        </div>
      </div>
    </div>
  </footer>
</div>
{{ template "jsdep"}}
</body>
</html>
