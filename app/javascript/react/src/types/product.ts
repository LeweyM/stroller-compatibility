export type Product = {
    id: number,
    name: string,
    slug: string,
    type: ProductType,
    image_url: string,
    brand_name: string,
    url: string,
}

export type CompatibleProduct = {
    from_link: boolean,
    product: Product,
    adapter?: Product,
}

export enum ProductType {
    Stroller = "Stroller",
    Seat = "Seat",
    Adapter = "Adapter"
}

export type ProductFilters = {
    types: ProductType[]
    names: string[]
}