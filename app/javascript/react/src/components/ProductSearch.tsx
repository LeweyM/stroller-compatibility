import React from "react";
import {ProductFilters} from "../types/product";
import {useProductSearchClient} from "../hooks/useProductSearchClient";
import AsyncSelect from "react-select/async";

type SearchWrapperProps = {
    onChange: (selected: string) => void,
    searchUrl: string,
    filter?: Filter,
};

type Filter = Partial<ProductFilters>

export const ProductSearch = ({onChange, searchUrl, filter = {}}: SearchWrapperProps) => {
    const {debouncedLoader} = useProductSearchClient(searchUrl);

    return <AsyncSelect
        cacheOptions
        defaultOptions
        loadOptions={debouncedLoader(filter)}
        onChange={(selected: any) => onChange(selected.value)}
    />
};