# README

## Deployment

### fly.io

This app is deployed on fly.io.

Use the following command to deploy:
```bash
flyctl deploy
```

### supabase

This app uses supabase for the postgres database.

The secrets are set as follows:

```bash
fly secrets set DATABASE_URL=xxxx
```

## Todos:

- [x] deployment to fly.io and supabase
- [ ] hosting on a domain
- [ ] admin user for updating brands
- [ ] view strollers for a brand
- [ ] view seats for a brand
- [ ] view compatibility of a seat and a stroller
- [ ] active filtering dropdown for products
- [ ] populate initial product database from https://www.babylist.com/hello-baby/car-seat-stroller-compatibility
- [ ] pipeline to process amazon reviews for compatibility information