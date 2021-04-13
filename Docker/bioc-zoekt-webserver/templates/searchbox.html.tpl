
<form action="search">
  <div class="form-row">
    <div class="col-12 col-sm-9 offset-sm-1">
      <input class="form-control" placeholder="Search for some code..." autofocus
              {{if .Query}}
              value={{.Query}}
              {{end}}
              id="searchbox" type="text" name="q">
    </div>
    <div class="col-sm-2 d-none d-sm-inline">
      <button type="submit" class="btn btn-primary">Search</button>
    </div>
  </div>
</form>
