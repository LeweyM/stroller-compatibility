import React, {Fragment, useEffect} from "react";
import {Product, ProductFilters} from "../types/product";
import {useProductSearchClient} from "../hooks/useProductSearchClient";
import _ from "lodash";
import AsyncSelect from "react-select/async";
import {usePrevious} from "../hooks/usePrevious";

type Props = {
    initialProducts: Product[],
    searchUrl: string,
    addLinkUrl: string,
    unlinkUrl: string,
    filter?: Filter,
    adapter?: Product,
};

type Filter = Partial<ProductFilters> & { not?: Partial<ProductFilters> }

type Item = {
    value: string,
    label: string,
    loaded: boolean | undefined
}

export const MultiProductSearch = ({
                                       initialProducts,
                                       searchUrl,
                                       addLinkUrl,
                                       unlinkUrl,
                                       adapter,
                                       filter = {}
                                   }: Props) => {
    const {query} = useProductSearchClient(searchUrl);
    const [value, setValue] = React.useState<Item[]>(initialProducts.map(p => ({
        value: p.slug,
        label: p.name,
        loaded: true,
    })))
    const previousValue = usePrevious(value);
    function setItemLoaded(nextItemSlug: string, loaded: boolean | undefined = true) {
        setValue((v: Item[]) => {
            return v.map(item => {
                if (item.value === nextItemSlug) {
                    return {...item, loaded}
                }
                return item
            })
        })
    }

    useEffect(() => {
        if (!(previousValue && !_.isEqual(previousValue, value))) return;

        const previousSlugs = previousValue.map(p => p.value);
        const newItems = value.filter(
            item => !previousValue.find(previousItem => previousItem.value === item.value)
        )
        if (newItems.length === 1) {
            const newItemSlug = newItems[0].value;
            const otherItemSlugs = previousSlugs.filter(item => item !== newItemSlug)

            Promise.all(otherItemSlugs.map(otherItem => saveProductUpdate("POST", addLinkUrl, newItemSlug, otherItem)))
                .then(() => setItemLoaded(newItemSlug))
        }
        const oldItemSlugs = previousSlugs.filter(
            slug => !value.find(item => item.value === slug)
        )
        if (oldItemSlugs.length === 1) {
            const oldItemSlug = oldItemSlugs[0];
            const otherItemSlugs = value.map(i => i.value).filter(slug => slug !== oldItemSlug)

            Promise.all(otherItemSlugs.map(otherItem => saveProductUpdate("DELETE", unlinkUrl, oldItemSlug, otherItem)))
                .then(() => console.log(`successfully removed links for ${otherItemSlugs.length} products`))
        }
    }, [value])

    const saveProductUpdate = async (method: "POST" | "DELETE", url: string, productA: string, productB: string): Promise<Response> => {
        // @ts-ignore
        const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
        return fetch(url, {
            method: method,
            // @ts-ignore
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken
            },
            body: JSON.stringify({
                adapter: adapter?.slug || null,
                product_a: productA,
                product_b: productB,
            })
        })
    };

    const debouncedLoader =
        _.debounce((inputValue: string, callback: Function) => {
                query(inputValue, filter).then((res) => {
                    return res && callback(res)
                });
            }, 700
        );

    return <Fragment>
        <AsyncSelect
            isMulti
            defaultOptions
            formatOptionLabel={({label, loaded}, meta) => {
                if (meta.context === 'menu') return label;
                return loaded
                    ? <span>{label}</span>
                    : <span><i className="fa-solid fa-spinner fa-spin px-2"></i>{label}</span>
            }}
            value={value}
            isClearable={false}
            closeMenuOnSelect={false}
            loadOptions={debouncedLoader}
            onChange={(selected: any) => {
                setValue(selected);
            }}
            cacheOptions
        />
    </Fragment>
};