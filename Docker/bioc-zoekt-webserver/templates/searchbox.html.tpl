
<form action="search">
  <div class="form-row">
    <div class="col-sm-1 col-xs-0">
    </div>
    <div class="col-sm-9 col-xs-11">
      <input class="form-control" placeholder="Search for some code..." autofocus
              {{if .Query}}
              value={{.Query}}
              {{end}}
              id="searchbox" type="text" name="q">
    </div>
    <div class="col-sm-2 col-xs-1">
      <button type="submit" class="btn btn-primary">Search</button>
    </div>
  </div>
</form>
