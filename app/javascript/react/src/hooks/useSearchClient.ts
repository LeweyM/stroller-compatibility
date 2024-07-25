import {useRef, useState} from 'react';

type APIResponseItem = {
    slug: string
    name: string
    brand: string
}

const useSearchClient = (url: string) => {
    const controller = useRef<AbortController>();
    const [searchResults, setSearchResults] = useState<APIResponseItem[]>([]);
    const [loading, setLoading] = useState(false);

    const fetchData = async (query: string) => {
        if (controller.current) {
            controller.current.abort();
        }
        controller.current = new AbortController();

        setLoading(true);
        try {
            const response = await fetch(`${url}?search_term=${query}`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                },
                signal: controller.current.signal,
            });
            if (response.ok) {
                return await response.json()
            } else {
                console.error('Failed to fetch data');
            }
        } catch (error) {
            console.error('Error fetching data:', error);
        } finally {
            setLoading(false);
        }
    };

    return { searchResults, loading, fetchData };
};

export default useSearchClient;
