import {parseQueryParams} from "../utils/requestUtils";
import useSingleFlightOnlyClient from "./useSingleFlightOnlyClient";
import {ProductFilters} from "../types/product";

export type APIResponseItem = {
    slug: string
    name: string
    brand: string
}

type Filter = Partial<ProductFilters>

type SearchResult = {
    value: string,
    label: string
}

export const useProductSearchClient = (searchUrl: string) => {
    const client = useSingleFlightOnlyClient<APIResponseItem[]>();

    const query = async (input: string, filter: Filter): Promise<SearchResult[]> => {
        const queryParams = {
            type: filter?.types,
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
    }

    return {query};
};