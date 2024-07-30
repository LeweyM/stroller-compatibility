# README

## Development

### React

react has been setup using esbuild.

Followed the excellent guide here: https://ryanbigg.com/2023/06/rails-7-react-typescript-setup

Yarn is used to rebuild the app assets, so use `yarn build --watch` to rebuild any changed files in dev.

Add a new component using the ReactComponent class
```erb
<%= render ReactComponent.new("App") %>
```

`App` is defined in `app/javascript/react/src/components` and uses the mount helper.

We can package this in a ruby class as follows
```ruby
module Products
  class ShowComponent < ReactComponent
    def initialize(raw_props)
      super("Product", raw_props: raw_props)
    end

    def props
      raw_props.merge(
        price: helpers.number_to_currency(raw_props[:price])
      )
    end
  end
end
```

and then use it in the view like so

```erb
<%= render Products::ShowComponent.new(name: "Shoes", price: 100) %>
```

## Local Development

### TLDR;
```bash
yarn build --watch # rebuilds assets on change
```
```bash
pg_ctl -D ~/postgres-data -l ~/postgres-data/server.log start
```
```bash
bin/dev
```

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

- [ ] Build The App
    - [x] view strollers for a brand
    - [x] view seats for a brand
    - [x] view compatibility of a seat and a stroller
    - [x] urls for products should be name not id
    - [x] active filtering dropdown for products
    - [x] basic UI designs
    - [x] product images
    - [x] default product images
    - [x] button to 'select another product' for product_a on fits page
    - [x] set brand on the product model, not submodels
    - [ ] admin user for updating products and brands
    - [ ] responsive flow for mobile
    - [ ] logo header
    - [ ] CI pipeline for deployment on push
    - [ ] image CDN
- [ ] Populate The DB
    - [ ] populate initial product database from https://www.babylist.com/hello-baby/car-seat-stroller-compatibility
    - [ ] populate initial product database maxicosi compatibility pdf
    - [ ] import product data via csv (script?)
    - [ ] pipeline to process amazon reviews for compatibility information
- [ ] Market
    - [ ] hosting on a domain
    - [ ] seo optimization for combinatorial urls
    - [ ] post to some blogs / forums
- [ ] Profit
    - [ ] legally using images
    - [ ] set up affiliate marketing accounts
    - [ ] affiliate marketing links
    - [ ] google analytics
