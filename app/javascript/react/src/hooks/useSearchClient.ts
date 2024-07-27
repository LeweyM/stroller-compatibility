import useSingleFlightOnlyClient from "./useSingleFlightOnlyClient";

export type APIResponseItem = {
    slug: string
    name: string
    brand: string
}

const useSearchClient = (url: string) => {
    const client = useSingleFlightOnlyClient<APIResponseItem[]>();

    const searchByQuery = async (query: string) => {
        return await client.fetchData(`${url}?search_term=${query}`);
    };

    return { searchByQuery };
};

export default useSearchClient;
