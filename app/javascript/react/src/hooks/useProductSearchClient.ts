import {parseQueryParams} from "../utils/requestUtils";
import useSingleFlightOnlyClient from "./useSingleFlightOnlyClient";
import {ProductFilters} from "../types/product";
import _ from "lodash";
import {GroupBase, OptionsOrGroups} from "react-select";

export type OptionType = {
    value: string;
    label: string;
};
export type APIResponseItem = {
    slug: string
    name: string
    brand: string
}

export type Filter = Partial<ProductFilters> &
    {
        not?: Partial<ProductFilters>,
        page?: number
    }

export const useProductSearchClient = (searchUrl: string) => {
    const client = useSingleFlightOnlyClient<APIResponseItem[]>();

    const query = async (input: string, filter: Filter): Promise<APIResponseItem[]> => {
        const queryParams = {
            type: filter?.types,
            search_term: input != "" ? input : undefined,
            exclude_names: filter?.not?.names,
            exclude_types: filter?.not?.types,
            page: filter.page || 0,
        }
        const url = `${searchUrl}?${parseQueryParams(queryParams)}`
        const results = await client.fetchData(url)
        if (!results) {
            return []
        }
        return results
    }

    const groupResponseByBrand = (res: APIResponseItem[]) => {
        const resultsByBrand = _.groupBy(res, 'brand');
        return _.map(resultsByBrand, (results, brand) => ({
            label: brand,
            options: results.map(r => ({
                value: r.slug,
                label: r.name
            }))
        }))
    }

    const paginatedLoader = (filter: Filter) => async (
        searchInput: string,
        prevOptions: OptionsOrGroups<OptionType, GroupBase<OptionType>>,
        additional?: { page: number }
    ) => {
        const page = additional?.page || 0;
        const res = await query(searchInput, {...filter, page});
        return {
            options: groupResponseByBrand(res),
            hasMore: res.length > 0,
        };
    }

    const debouncedLoader = (filter: Filter, waitMs: number = 700) =>
        _.debounce((inputValue: string, callback: Function) => {
                query(inputValue, filter).then((res) => {
                    if (!res) return;
                    return callback(groupResponseByBrand(res));
                });
            }, waitMs
        )

    return {query, debouncedLoader, paginatedLoader};
};