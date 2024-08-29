import {useRef} from 'react';

const useSearchClient = <T>() => {
    const controller = useRef<AbortController>();

    const fetchData = async (url: string): Promise<T | undefined> => {
        if (controller.current) {
            controller.current.abort('debounced-request');
        }
        controller.current = new AbortController();
        try {
            const response = await fetch(url, {signal: controller.current.signal});
            if (response.ok) {
                return await response.json()
            } else {
                console.error('Failed to fetch data');
            }
        } catch (error) {
            if (error === 'debounced-request') {
                console.log('Aborted request');
                return;
            } else {
                console.error('Error fetching data:', error, url);
                throw error
            }
        }
    };

    return { fetchData };
};

export default useSearchClient;
