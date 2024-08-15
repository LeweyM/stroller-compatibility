export enum ProductType {
    Stroller = "Stroller",
    Seat = "Seat",
    Adapter = "Adapter"
}

export type ProductFilters = {
    types: ProductType[]
}