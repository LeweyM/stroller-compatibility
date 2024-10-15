export type Product = {
    id: number,
    name: string,
    slug: string,
    type: ProductType,
    image: Image,
    brand_name: string,
    url: string,
}

export type Image = {
    url: string,
    alt_text: string,
    attribution_text: string,
    attribution_url: string,
}

export type Tag = {
    label: string,
}

export type CompatibleProduct = {
    tags: Tag[],
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