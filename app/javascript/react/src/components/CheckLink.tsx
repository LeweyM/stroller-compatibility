import React, {useState, useEffect, PropsWithChildren} from 'react';

type CheckLinkProps = {
    productId: string,
    checkLinkPath: string
};

enum requestStatus {
    pending,
    error ,
    good_link,
    bad_link,
}

const CheckLinkElement = ({status, code}: { status: requestStatus, code: number }) => {
    const color = {
        [requestStatus.pending]: 'text-gray-500',
        [requestStatus.error]: 'text-red-500',
        [requestStatus.good_link]: 'text-green-500',
        [requestStatus.bad_link]: 'text-red-500',
    }[status]

    const text = {
        [requestStatus.pending]: 'Checking...',
        [requestStatus.error]: `Error`,
        [requestStatus.good_link]: 'Good Link',
        [requestStatus.bad_link]: `Bad Link (${code})`,
    }[status]

    return <div className={`p-4 text-center ${color} text-xs font-bold rounded-full bg-blue-100 mx-2`}>
        {text}
    </div>;
}

const CheckLink = ({productId, checkLinkPath}: CheckLinkProps) => {
    const [status, setStatus] = useState<requestStatus>(requestStatus.pending);
    const [code, setCode] = useState<number>(0);

    useEffect(() => {
        const fetchStatus = async () => {
            try {
                // @ts-ignore
                const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
                const response = await fetch(checkLinkPath, {
                    method: 'POST',
                    // @ts-ignore
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-Token': csrfToken
                    },
                    body: JSON.stringify({product_id: productId}),
                });

                const data = await response.json();
                const code = data["response_status"];
                setCode(code)
                setStatus(code === 200 ? requestStatus.good_link : requestStatus.bad_link);
            } catch (error) {
                console.error('Error:', error);
                setStatus(requestStatus.error);
            }
        };

        fetchStatus();
    }, [productId, checkLinkPath]);

    return <CheckLinkElement status={status} code={code}/>
}

export default CheckLink;