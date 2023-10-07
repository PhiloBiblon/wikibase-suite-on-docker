# Wikibase suite on docker

A collection of Wikibase services installed via Docker Compose V2:
* Wikibase
* Query Service
* QuickStatements
* OpenRefine
* Reconcile Service

Based on the [example of wikibase-release-pipeline](https://github.com/wmde/wikibase-release-pipeline/tree/main/example) repository.

All the services are accessed through a single URL through the https protocol configured using a [Let's Encrypt](https://letsencrypt.org/) certificate.

## Requirements

* Install [Docker Compose V2](https://docs.docker.com/compose/install/).
* A DNS name for your server.

## Install

1. Move to the `services` folder.

2. Configure parameters. 
  1. Replace at least the following parameters in .env file.
     * `SITENAME`. Sitename for your site.
     * `VIRTUAL_HOST`. Your server dns name.
     * `LETSENCRYPT_EMAIL`. An email to use with LetsEncrypt
     * `MW_ADMIN_PASS`. Wikibase password.
     * `MW_SECRET_KEY`.
     * `DB_PASS`. Internal database password.
  2. Apply custom parameters.
```
. .env
envsubst '$SITENAME,$VIRTUAL_HOST' < wiki/LocalSettings.php.template > wiki/LocalSettings.php
envsubst '$SITENAME,$VIRTUAL_HOST' < wiki/pages/MediaWiki\:SideBar.template > wiki/pages/MediaWiki\:SideBar
envsubst '$SITENAME,$VIRTUAL_HOST' < reconcile/config.py.template > reconcile/config.py
```
 
3. Replace your logo. Replace the `wiki/wiki.png` image for your own logo.

4. Create suite.
```
docker compose up -d
```

## Access to the services

* Wikibase: `https://${VIRTUAL_HOST}/query/`
* Query service: `https://${VIRTUAL_HOST}/query/`
* Quickstatements: `https://${VIRTUAL_HOST}/qs/`
* Reconcile service: `https://${VIRTUAL_HOST}/reconcile/`
* OpenRefine: `https://${VIRTUAL_HOST}/openrefine/`
* OpenRefine (files): `https://${VIRTUAL_HOST}/openrefine-data/`

## Useful commands

### Stop all the services
```
docker compose stop
```

### Start again all the services
```
docker compose start
```

### Retart all the services
```
docker compose start
```

### Backup
This is a backup at docker volume level, so if some service is upgraded to a new version, backward compatibility is not guaranteed.
The backup is stored inside `~/backup` folder.
```
./backup.sh
```

### Restore
Restore a previous backup.
```
./restore.sh <backup folder name>
```

## Additional config

### Access all service from Wikibase page

1. Access to: `https://${VIRTUAL_HOST}/wiki/MediaWiki:SideBar`.
2. Edit the page with the content from your `wiki/pages/MediaWiki:SideBar`.

### Disable anonymous edits

1. Edit the your `wiki/LocalSettings.php` and add the following lines and restart the services.
```
$wgGroupPermissions['*']['edit'] = false;
$wgGroupPermissions['*']['createaccount'] = false;
```

## Troubleshooting

### Insecure certificate warning when accessed by browser

Check ACME companion logs for more details:
```
docker logs services-acme-companion-1
```
In case you see a [rate limits|https://letsencrypt.org/docs/rate-limits/] error, try to enable LetsEncrypt debug during your tests to avoid exceeding the rate limits.
Uncomment `LETS_ENCRYPT_TEST: true` in `docker-compose.proxy.yml` and restart the services.

### WDQS updater container fails to start

Check logs for more details:
```
docker logs services-wdqs-updater-1
```

If you can see an error like: `java.lang.IllegalStateException: RDF store reports the last update time is before the minimum safe poll time.`,
uncomment parameter `WIKIBASE_MAX_DAYS_BACK` in `.env`file setting an enough number of days and restart the services.
