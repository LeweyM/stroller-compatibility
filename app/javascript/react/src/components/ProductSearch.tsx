import React from "react";
import {ProductFilters} from "../types/product";
import {OptionType, useProductSearchClient} from "../hooks/useProductSearchClient";
import {AsyncPaginate, LoadOptions, reduceGroupedOptions} from 'react-select-async-paginate';
import {GroupBase} from "react-select";

type SearchWrapperProps = {
    onChange: (selected: string) => void,
    searchUrl: string,
    filter?: Filter,
};

type Filter = Partial<ProductFilters>

type AdditionalType = {
    page: number;
};

const defaultAdditional: AdditionalType = {
    page: 0
};

export const ProductSearch = ({onChange, searchUrl, filter = {}}: SearchWrapperProps) => {
    const {paginatedLoader} = useProductSearchClient(searchUrl);

    const loadOptionsWrapper: LoadOptions<
        OptionType,
        GroupBase<OptionType>,
        AdditionalType
    > = async (q, prevOptions, additional) => {
        const { page } = additional || defaultAdditional;
        const { options, hasMore } = await paginatedLoader({...filter, page })(q, prevOptions, additional);

        return {
            options,
            hasMore,
            additional: {
                page: page + 1
            }
        };
    };

    return <AsyncPaginate
        defaultAdditional={defaultAdditional}
        defaultOptions
        debounceTimeout={700}
        reduceOptions={reduceGroupedOptions}
        loadOptions={loadOptionsWrapper}
        onChange={(selected: any) => onChange(selected.value)}
    />
};