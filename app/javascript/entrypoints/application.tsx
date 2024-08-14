import React from "react";
import mount from "../mount";
import {Search} from "../react/src/components/Search";
import useSingleFlightOnlyClient, {APIResponseItem} from "../react/src/hooks/useSingleFlightOnlyClient";
import CheckLink from "../react/src/components/CheckLink";

function parseQueryParams(queryParams: Record<string, any>) {
    return Object.entries(queryParams)
        .filter(([key, value]) => value !== undefined)
        .flatMap(([key, value]) => {
            if (Array.isArray(value)) {
                return value.map(v => `${encodeURIComponent(key)}[]=${encodeURIComponent(v)}`)
            }
            return `${encodeURIComponent(key)}=${encodeURIComponent(value)}`
        })
        .join('&')
}

const SearchProduct = ({searchUrl}: { searchUrl: string }) => {
    const client = useSingleFlightOnlyClient<APIResponseItem[]>();

    let getData = async (input: string) => {
        const queryParams = {
            search_term: input != "" ? input : undefined,
            type: [ProductType.Stroller]
        }
        const results = await client.fetchData(`${searchUrl}?${parseQueryParams(queryParams)}`);
        if (!results) {
            return []
        }
        return results.map((result) => ({
            value: result.slug,
            label: result.name
        }))
    };

    const onChange = (selected: string) =>
        window.location.href = `${selected}/fits`;

    return <Search
        onChange={onChange}
        getData={getData}
        debounce={700}
    />
}

enum ProductType {
    Stroller = "Stroller",
    Seat = "Seat",
    Adapter = "Adapter"
}

type Product = {
    slug: string,
    name: string,
    productable_type: ProductType
    // brand: string
}

const SearchComparisonProduct = ({searchUrl, product, types}: { searchUrl: string, product: Product, types?: ProductType[] }) => {
    const client = useSingleFlightOnlyClient<APIResponseItem[]>();

    const typeFilter = types || {
        [ProductType.Seat]: [ProductType.Stroller],
        [ProductType.Stroller]: [ProductType.Seat],
        [ProductType.Adapter]: [ProductType.Stroller, ProductType.Seat],
    }[product.productable_type]

    let getData = async (input: string) => {
        const queryParams = {
            type: typeFilter,
            search_term: input != "" ? input : undefined,
        }
        const url = `${searchUrl}?${parseQueryParams(queryParams)}`
        const results = await client.fetchData(url)
        if (!results) {
            return []
        }
        return results.map((result) => ({
            value: result.slug,
            label: result.name
        }))
    };

    const onChange = (selected: string) =>
        window.location.href = `${window.location.href}/${selected}`;

    return <Search
        onChange={onChange}
        getData={getData}
        debounce={700}
    />
}


mount({
    SearchProduct,
    SearchComparisonProduct,
    CheckLink
})