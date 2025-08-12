# gitlist — Git Browser Component for code.bioconductor.org

## Description
The `gitlist` directory contains the Dockerized GitList web application used to browse Bioconductor package repositories.  

## Architecture

The service runs as two cooperating processes inside a single container:

- **nginx** – A lightweight web server that:
  - Listens for HTTP requests from clients.
  - Serves static assets (CSS, JS, images) directly for speed.
  - Forwards requests that require PHP processing to `php-fpm`.

- **php-fpm** – The PHP FastCGI Process Manager that:
  - Runs the GitList PHP code.
  - Handles dynamic requests like rendering repository views, diffs, and commit history.
  - Returns generated HTML back to `nginx` over a FastCGI interface.

**Flow of a request:**
1. User requests a GitList page (e.g., `/packages/myPackage/commit/1234`).
2. `nginx` checks if it’s a static file — if not, it proxies the request to `php-fpm` via FastCGI.
3. `php-fpm` executes the GitList PHP code, which reads from the Git repositories mounted at `/var/git`.
4. The generated HTML is sent back through `nginx` to the user’s browser.

This separation allows:
- Static files to be served very quickly without touching PHP.
- PHP code to run in a managed, pooled environment (improving performance and stability).

## GoAccess Web Logs

The GitList service’s access logs are analysed using **[GoAccess](https://goaccess.io/)**, a real-time log analyzer.  
The GoAccess output is published as a password-protected dashboard at: https://code.bioconductor.org/logs

### GoAccess Features:

- Tracks visitor counts, request types, most popular repositories/pages.
- Monitors response codes, referrers, and bandwidth usage.
- Generates a live HTML report updated every second.
- The `/logs` endpoint is protected by HTTP Basic Authentication configured in `nginx`. Contact Mike Smith for details on the password or update the `nginx-auth-secret` in kubernetes.

## Log Rotation & Maintenance

To prevent large log files from filling the disk:
- **`logrotate`** is configured to:
  - Rotate `nginx` access and error logs on a daily schedule retaining the last 90 days.
  - Trigger GoAccess processing after rotation so that stats are up-to-date.

- **Kubernetes CronJob**:
  - Runs `logrotate` daily to ensure log files are rotated without manual intervention.
  - Sends a `kill -USR1 1` message to the pods running `nginx` and `goaccess` to ensure they start using the newly created log files.

