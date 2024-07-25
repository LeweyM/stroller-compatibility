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
yarb build --watch # rebuilds assets on change
pg_ctl -D ~/postgres-data -l ~/postgres-data/server.log start
bin/rails s # starts rails server
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

- [x] deployment to fly.io and supabase
- [x] view strollers for a brand
- [x] view seats for a brand
- [x] view compatibility of a seat and a stroller
- [x] urls for products should be name not id
- [ ] active filtering dropdown for products
- [ ] hosting on a domain
- [ ] admin user for updating brands
- [ ] populate initial product database from https://www.babylist.com/hello-baby/car-seat-stroller-compatibility
- [ ] pipeline to process amazon reviews for compatibility information