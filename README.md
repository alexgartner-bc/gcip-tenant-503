## Reproducer Steps

- enable multi-tenancy via the console: https://cloud.google.com/identity-platform/docs/multi-tenancy-quickstart
- set project id in main.tf
- create service account with owner role on project
- `export GOOGLE_APPLICATION_CREDENTIALS=~/keys/gcip-503-reproducer.json`
- `terraform apply`
- `terraform output -json > outputs.json`
- copy the tenant ids from `outputs.json` to `settings.json`
- `gcloud iap settings set --project bc-roc-poc --resource-type=compute --service gcip-tenant-503 settings.json`

## Symptoms

`gcloud` command hangs for 2-3 minutes then you get:

```
➜  gcip-tenant-503 git:(main) ✗ gcloud iap settings set --project bc-roc-poc --resource-type=compute --service gcip-tenant-503 settings.json
ERROR: (gcloud.iap.settings.set) HttpError accessing <https://iap.googleapis.com/v1/projects/bc-roc-poc/iap_web/compute/services/gcip-tenant-503:iapSettings?alt=json>: response: <{'vary': 'Origin, X-Origin, Referer', 'content-type': 'application/json; charset=UTF-8', 'content-encoding': 'gzip', 'date': 'Mon, 10 Apr 2023 21:00:03 GMT', 'server': 'ESF', 'cache-control': 'private', 'x-xss-protection': '0', 'x-frame-options': 'SAMEORIGIN', 'x-content-type-options': 'nosniff', 'alt-svc': 'h3=":443"; ma=2592000,h3-29=":443"; ma=2592000', 'transfer-encoding': 'chunked', 'status': 503}>, content <{
  "error": {
    "code": 503,
    "message": "The service is currently unavailable.",
    "status": "UNAVAILABLE"
  }
}
```
