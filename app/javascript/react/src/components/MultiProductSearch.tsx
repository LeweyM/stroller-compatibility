import React, {Fragment, useEffect} from "react";
import {CompatibleProduct, Product, ProductFilters} from "../types/product";
import {useProductSearchClient} from "../hooks/useProductSearchClient";
import _ from "lodash";
import AsyncSelect from "react-select/async";
import {usePrevious} from "../hooks/usePrevious";
import {StylesConfig} from "react-select";

type Props = {
    initialProducts: CompatibleProduct[],
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
    loaded: boolean | undefined,
    isFixed: boolean,
}

const orderOptions = (values: readonly Item[]) => {
    return values
        .filter((v) => v.isFixed)
        .concat(values.filter((v) => !v.isFixed));
};

export const MultiProductSearch = ({
                                       initialProducts,
                                       searchUrl,
                                       addLinkUrl,
                                       unlinkUrl,
                                       adapter,
                                       filter = {}
                                   }: Props) => {
    const {debouncedLoader} = useProductSearchClient(searchUrl);
    const [value, setValue] = React.useState<Item[]>(orderOptions(initialProducts.map(cp => ({
        value: cp.product.slug,
        label: cp.product.name,
        loaded: true,
        isFixed: cp.from_link
    }))));
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
        if (!previousValue || _.isEqual(previousValue, value)) return;

        const previousSlugs = previousValue
            .filter(p => !p.isFixed)
            .map(p => p.value);
        const newItems = value
            .filter(p => !p.isFixed)
            .filter(item => !previousValue.find(previousItem => previousItem.value === item.value))
        if (newItems.length === 1) {
            const newItemSlug = newItems[0].value;

            saveProductUpdate("POST", addLinkUrl, newItemSlug)
                .then(() => setItemLoaded(newItemSlug))
        }
        const oldItemSlugs = previousSlugs.filter(
            slug => !value.find(item => item.value === slug)
        )
        if (oldItemSlugs.length === 1) {
            const oldItemSlug = oldItemSlugs[0];

            saveProductUpdate("DELETE", unlinkUrl, oldItemSlug)
                .then(() => console.log(`successfully removed link for ${oldItemSlug}`))
        }
    }, [value])

    const saveProductUpdate = async (method: "POST" | "DELETE", url: string, productA: string): Promise<Response> => {
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
            })
        })
    };

    const styles: StylesConfig<Item, true> = {
        multiValue: (base, state) => {
            return state.data.isFixed ? {...base, backgroundColor: 'gray'} : base;
        },
        multiValueLabel: (base, state) => {
            return state.data.isFixed
                ? {...base, fontWeight: 'bold', color: 'white', paddingRight: 6}
                : base;
        },
        multiValueRemove: (base, state) => {
            return state.data.isFixed ? {...base, display: 'none'} : base;
        },
    };

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
            loadOptions={debouncedLoader(filter)}
            onChange={(selected: any) => {
                setValue(selected);
            }}
            cacheOptions
            styles={styles}
        />
    </Fragment>
};