import React from "react";
import mount from "../mount";
import CheckLink from "../react/src/components/CheckLink";
import {ProductType} from "../react/src/types/product";
import {ProductSearch} from "../react/src/components/ProductSearch";
import {MultiProductSearch} from "../react/src/components/MultiProductSearch";
import ProductCarousel from "../react/src/components/ProductCarousel";


mount({
    SearchProduct: ({searchUrl, types}: { searchUrl: string, types?: ProductType[] }) => {
        return <ProductSearch
            onChange={(selected: string) =>
                window.location.href = `${selected}/fits`}
            searchUrl={searchUrl}
            filter={{
                types: types
            }}
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
    SearchProductMulti: MultiProductSearch,
    CheckLink,
    ProductCarousel
})