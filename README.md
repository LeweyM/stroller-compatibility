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

### Tailwindcss

uses the tailwindcss-rails gem for tailwind integration

#### in production

css is compiled by `rails assets:precompile`, run as part of docker image step

#### in development

Any changes to files are watched and trigger css rebuild. The Procfile ensures that `tailwindcss:build` is run on any changes.

> **Warning**
> Make sure that the precompiled assets have been removed if you've run `rails assets:precompile` locally. They will be used by default and changes won't be picked up!!

## Local Development

### Run the app locally against a local database
```bash
make setup-local-db
make start-local-db
make local
```

#### restart the local database
```bash
make restart-local-db
```

#### teardown the local database
```bash
make teardown-local-db
```

### Run the app locally against the production database

```bash
make local-production
```


## Deployment

### CI

The app is deployed via github actions which runs on every push to main branch.

Migrations are automatically run on deployment.

#### Push without deployment

To skip the deployment when commiting, include `[skip ci]` in the commit message, i.e: 
```
git commit -m "ci: [skip ci] update README.md" 
```

### fly.io

This app is deployed on fly.io.

#### Deploy the app to production
```bash
flyctl deploy
```

#### View the app in production
```bash
fly open
```

### supabase

This app uses supabase for the postgres database.

The secrets are set as follows:

```bash
fly secrets set DATABASE_URL=xxxx
```

## Todos:

- [x] Build The App
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
    - [x] admin user for updating products and brands
    - [x] responsive flow for mobile
    - [x] logo header
    - [x] CI pipeline for deployment on push
    - [ ] image CDN
- [ ] Populate The DB
    - [x] export data to CSV
    - [x] automated image search based on product name
    - [x] 100 products ready (41/100)
    - [x] automated product url based on product name
    - [ ] automated url fixing for 301 links
    - [x] populate initial product database from https://www.babylist.com/hello-baby/car-seat-stroller-compatibility
    - [x] populate initial product database maxicosi compatibility pdf
    - [x] import product data via csv in admin panel
    - [ ] pipeline to process amazon reviews for compatibility information
    - [ ] product tagging
      - [ ]
- [ ] Market
    - [x] hosting on a domain
    - [ ] seo optimization for combinatorial urls
    - [ ] post to some blogs / forums
- [ ] Profit
    - [ ] legally using images
    - [ ] set up affiliate marketing accounts
    - [ ] affiliate marketing links
    - [ ] google analytics
