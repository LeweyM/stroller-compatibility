import React from "react";
import mount from "../mount";
import CheckLink from "../react/src/components/CheckLink";
import {ProductType} from "../react/src/types/product";
import {ProductSearch} from "../react/src/components/ProductSearch";

mount({
    SearchProduct: ({searchUrl}: { searchUrl: string }) => {
        return <ProductSearch
            onChange={(selected: string) =>
                window.location.href = `${selected}/fits`}
            searchUrl={searchUrl}
        />
    },
    SearchComparisonProduct: ({searchUrl, types}: { searchUrl: string, types?: ProductType[] }) => {
        return <ProductSearch
            onChange={(selected: string) =>
                window.location.href = `${window.location.href}/${selected}`}
            searchUrl={searchUrl}
            filter={{
                types: types
            }}
        />
    },
    CheckLink
})