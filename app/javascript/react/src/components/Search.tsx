import React from "react";
import AsyncSelect from 'react-select/async';
import _ from "lodash";

type SearchResult = {
    value: string,
    label: string
}

type SearchWrapperProps = {
    onChange: (selected: string) => void,
    getData: (input: string) => Promise<SearchResult[]>
    debounce?: number
};

const SearchWrapper = ({onChange, getData, debounce = 0}: SearchWrapperProps) => {
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
