import React from "react";
import AsyncSelect from 'react-select/async';
import _ from "lodash";
import useSearchClient from "../hooks/useSearchClient";

type SearchResult = {
    value: string,
    label: string
}

const SearchWrapper = (props: { searchUrl: string }) => {
    const {fetchData} = useSearchClient(props.searchUrl);

    const search = (inputValue: string) => {
        return new Promise<SearchResult[]>(async (resolve) => {
            const searchResults = await fetchData(inputValue);
            const mappedResults: SearchResult[] = searchResults.map((result: any) => {
                return {
                    value: result.slug,
                    label: result.name
                };
            });
            return resolve(mappedResults);
        });
    };

    const _loadSuggestions = (query: string, callback: any) => {
        search(query)
            .then(resp => callback(resp));
    };
    return <AsyncSelect
        cacheOptions
        defaultOptions
        loadOptions={_.debounce(_loadSuggestions, 400)}
        onChange={(selected: any) => window.location.href = selected.value + '/fits'}
    />
};

export const Search = SearchWrapper;
