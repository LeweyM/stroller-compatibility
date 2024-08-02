import React from "react";
import mount from "../mount";
import {Search} from "../react/src/components/Search";
import useSingleFlightOnlyClient, {APIResponseItem} from "../react/src/hooks/useSingleFlightOnlyClient";

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
    return <Search
        searchUrl={searchUrl}
        slugToUrl={(slug: string) => `${slug}/fits`}
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

const SearchComparisonProduct = ({searchUrl, product}: { searchUrl: string, product: Product }) => {
    const client = useSingleFlightOnlyClient<APIResponseItem[]>();

    const typeFilter = {
        [ProductType.Seat]: [ProductType.Stroller],
        [ProductType.Stroller]: [ProductType.Seat],
        [ProductType.Adapter]: [ProductType.Stroller, ProductType.Seat],
    }[product.productable_type].map(type => `type[]=${type}`).join('&');

    let getData = async (input: string) => {
        const url = `${searchUrl}?search_term=${input}&${typeFilter}`;
        const results = await client.fetchData(url)
        if (!results) {
            return []
        }
        return results.map((result) => ({
            value: result.slug,
            label: result.name
        }))
    };
    return <Search
        searchUrl={searchUrl}
        slugToUrl={(slug: string, prevUrl: string) => `${prevUrl}/${slug}`}
        getData={getData}
        debounce={700}
    />
}


mount({
    SearchProduct,
    SearchComparisonProduct,
})