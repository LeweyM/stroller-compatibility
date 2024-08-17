export type Product = {
    id: number,
    name: string,
    slug: string,
    type: ProductType
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