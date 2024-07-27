import React from "react";
import AsyncSelect from 'react-select/async';
import _ from "lodash";

type SearchResult = {
    value: string,
    label: string
}

type SearchWrapperProps = {
    searchUrl: string,
    slugToUrl: (slug: string, prevUrl: string) => string,
    getData: (input: string) => Promise<SearchResult[]>
    debounce?: number
};

const SearchWrapper = ({slugToUrl, getData, debounce = 0}: SearchWrapperProps) => {
    const onChange = (selected: string) =>
        window.location.href = slugToUrl(selected, window.location.pathname);

    const debouncedLoader =
        _.debounce((inputValue: string, callback: Function) => {
                getData(inputValue).then((res) => {
                    return res && callback(res);
                });
            }, debounce
        );

    return <AsyncSelect
        cacheOptions
        defaultOptions
        loadOptions={debouncedLoader}
        onChange={(selected: any) => onChange(selected.value)}
    />
};

export const Search = SearchWrapper;
