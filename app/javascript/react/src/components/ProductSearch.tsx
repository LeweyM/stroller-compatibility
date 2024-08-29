import React from "react";
import {ProductFilters} from "../types/product";
import {useProductSearchClient} from "../hooks/useProductSearchClient";
import _ from "lodash";
import AsyncSelect from "react-select/async";

type SearchWrapperProps = {
    onChange: (selected: string) => void,
    searchUrl: string,
    filter?: Filter,
};

type Filter = Partial<ProductFilters>

export const ProductSearch = ({onChange, searchUrl, filter = {}}: SearchWrapperProps) => {
    const {query} = useProductSearchClient(searchUrl);

    const debouncedLoader =
        _.debounce((inputValue: string, callback: Function) => {
                query(inputValue, filter).then((res) => {
                    return res && callback(res.map(r => ({
                        brand: r.brand,
                        value: r.slug,
                        label: r.name,
                    })));
                });
            }, 700
        );

    return <AsyncSelect
        cacheOptions
        defaultOptions
        loadOptions={debouncedLoader}
        onChange={(selected: any) => onChange(selected.value)}
    />
};