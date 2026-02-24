# Easy LAMP Install/Uninstall Script (Ubuntu / WSL)

This repository provides a Bash script to install or remove a LAMP stack with optional phpMyAdmin, Git, VS Code, and WordPress helpers.

## Target environment

- Ubuntu-based Linux distributions
- Windows Subsystem for Linux (WSL), preferably WSL2

Do not run this script on macOS directly.

## Quick start

```bash
curl -O -L https://raw.githubusercontent.com/typerhack/lamp-install-script/main/lamp-install.sh
chmod +x lamp-install.sh
./lamp-install.sh
```

The script uses `sudo` internally when needed.

## What the script can do

1. Install LAMP + phpMyAdmin
2. Uninstall LAMP components
3. Create a MySQL user
4. Change MySQL root password
5. Create a database and associated MySQL user
6. Install Git
7. Restart Apache/MySQL services
8. Run VS Code (`code .`) inside `~/webdev`
9. Reboot the system
10. Install VS Code
11. Install WordPress core into `/var/www/html/<project_name>`

## phpMyAdmin install notes

During phpMyAdmin setup prompts, use:

- Web server: `apache2`
- Configure database for phpMyAdmin with dbconfig-common: `No`

## Important behavior

- The script creates a `webdev` symlink in the invoking user's home directory pointing to `/var/www/html`.
- Apache config updates are appended only when missing to avoid duplicate lines on repeated runs.
- MySQL/database names are restricted to letters, numbers, and underscores.

## Known limitations

- The uninstall routines are broad and may need tuning per distro/version.
- The script is interactive and not designed for non-interactive CI usage.
- The script has not been tested against every Ubuntu release.

## Changelog

### v0.30.0

- Fixed broken MySQL root password change flow.
- Fixed broken database/user creation variable checks.
- Fixed typo breaking database workflow initialization.
- Fixed MySQL user creation query to use entered username/password.
- Made Apache config updates idempotent (no duplicate lines on reruns).
- Corrected ownership/shortcut behavior to use invoking user instead of root.
- Fixed VS Code run path to use `<invoking_user_home>/webdev`.
- Improved input handling and quoting for several password prompts.
- Fixed info test file creation to write via `sudo`.

### v0.29.3

- Fixed permissions for WordPress installation.
- Fixed typing mistakes.
- Fixed some password matching bugs.
- Added shortcut prompt and other minor fixes.
