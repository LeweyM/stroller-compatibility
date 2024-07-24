# README

## Local Development

### Setting up the db

Setup a folder for the postgres db 
```bash
mkdir -p ~/postgres-data
initdb -D ~/postgres-data
```

Start a postgres instance

```bash
pg_ctl -D ~/postgres-data -l ~/postgres-data/server.log start
```

Stop the postgres instance
```bash
pg_ctl -D ~/postgres-data stop
```

Run the migrations and seed the db
```bash
bin/rails db:migrate
bin/rails db:seed:replant
```

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
- [x] view strollers for a brand
- [x] view seats for a brand
- [x] view compatibility of a seat and a stroller
- [ ] urls for products should be name not id
- [ ] active filtering dropdown for products
- [ ] hosting on a domain
- [ ] admin user for updating brands
- [ ] populate initial product database from https://www.babylist.com/hello-baby/car-seat-stroller-compatibility
- [ ] pipeline to process amazon reviews for compatibility information