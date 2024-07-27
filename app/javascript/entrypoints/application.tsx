import React from "react";
import mount from "../mount";
import {Search} from "../react/src/components/Search";
import useSearchClient, {APIResponseItem} from "../react/src/hooks/useSearchClient";
import useSingleFlightOnlyClient from "../react/src/hooks/useSingleFlightOnlyClient";

const SearchProduct = ({searchUrl}: { searchUrl: string }) => {
    const {searchByQuery} = useSearchClient(searchUrl);

    let getData = async (input: string) => {
        const results = await searchByQuery(input)
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