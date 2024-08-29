import {parseQueryParams} from "../utils/requestUtils";
import useSingleFlightOnlyClient from "./useSingleFlightOnlyClient";
import {ProductFilters} from "../types/product";

export type APIResponseItem = {
    slug: string
    name: string
    brand: string
}

type Filter = Partial<ProductFilters> & { not?: Partial<ProductFilters> }

export const useProductSearchClient = (searchUrl: string) => {
    const client = useSingleFlightOnlyClient<APIResponseItem[]>();

    const query = async (input: string, filter: Filter): Promise<APIResponseItem[]> => {
        const queryParams = {
            type: filter?.types,
            search_term: input != "" ? input : undefined,
            exclude_names: filter?.not?.names,
            exclude_types: filter?.not?.types,
        }
        const url = `${searchUrl}?${parseQueryParams(queryParams)}`
        const results = await client.fetchData(url)
        if (!results) {
            return []
        }
        return results
    }

    return {query};
};