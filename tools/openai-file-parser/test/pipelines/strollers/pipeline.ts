import {Pipeline} from "../../../src/types";

enum steps {
    EXTRACT_STROLLER_DATA = 'EXTRACT_STROLLER_DATA',
    EXTRACT_SEAT_DATA = 'EXTRACT_SEAT_DATA',
    EXTRACT_ADAPTER_DATA = 'EXTRACT_ADAPTER_DATA',
    EXTRACT_COMPATIBILITY_DATA = 'EXTRACT_COMPATIBILITY_DATA',
}

const htmlPageExample = `<h4><strong>Baby Jogger</strong></h4>

<h5 id="citymini" class="section-anchor"><a href="https://www.babylist.com/gp/baby-jogger-city-mini-gt2-stroller/15095/882928" target="_blank">City Mini GT2</a> (adapters sold separately)</h5>

<p>Here are the infant car seats you can use with the Citi Mini 2/City Mini GT2 strollers. In order for the car seat to safely click into the stroller, you’ll need an adapter, which can be found in the <strong>adapter</strong> link next to each infant car seat brand.</p>

<ul>
<li><strong>Baby Jogger</strong> (adapter included with stroller): <a href="https://www.babylist.com/gp/baby-jogger-city-go-2-infant-car-seat/15094/219570" target="_blank">City GO</a></li>
<li><strong>Chicco</strong> (<a href="https://www.babylist.com/gp/baby-jogger-chicco-peg-perego-car-seat-adapter-for-city-mini-2-city-mini-gt2/15103/219587" target="_blank">adapter</a>): KeyFit, <a href="https://www.babylist.com/gp/chicco-keyfit-30-infant-car-seat-85b3d274-1ed6-4e2a-b2a6-f6f581d072d6/2378/902322" target="_blank">KeyFit 30</a>, KeyFit30 Zip and Fit2</li>
</ul>`;

const pipeline: Pipeline<steps> = {
    steps: [
        {
            name: steps.EXTRACT_STROLLER_DATA,
            source: 'ORIGIN',
            prompt: "extract stroller data. Give the result in csv format. Use the col headers, type,brand,name,url,image_url",
            examples: [
                {
                    given: htmlPageExample,
                    then: `type,brand,name,url,image_url
Stroller,Baby Jogger,City Mini GT2,https://www.babylist.com/gp/baby-jogger-city-mini-gt2-stroller/15095/882928,`,
                }
            ],
            targetExtension: 'csv',
        },
        {
            name: steps.EXTRACT_SEAT_DATA,
            source: 'ORIGIN',
            prompt: "extract seat data. Give the result in csv format. Use the col headers, type,brand,name,url,image_url",
            examples: [
                {
                    given: htmlPageExample,
                    then: `type,brand,name,url,image_url
Seat,Baby Jogger,City GO,https://www.babylist.com/gp/baby-jogger-city-go-2-infant-car-seat/15094/219570,
Seat,Chicco,KeyFit,,
Seat,Chicco,KeyFit 30,https://www.babylist.com/gp/chicco-keyfit-30-infant-car-seat-85b3d274-1ed6-4e2a-b2a6-f6f581d072d6/2378/902322,
Seat,Chicco,KeyFit 30 zip,,
Seat,Chicco,Fit2,,`,
                }
            ],
            targetExtension: 'csv',

        },
        {
            name: steps.EXTRACT_ADAPTER_DATA,
            prompt: "extract adapter data. Give the result in csv format. Use the col headers, type,brand,name,url,image_url",
            source: 'ORIGIN',
            examples: [
                {
                    given: htmlPageExample,
                    then: `type,brand,name,url,image_url
Adapter,Chicco,KeyFit,https://www.babylist.com/gp/baby-jogger-chicco-peg-perego-car-seat-adapter-for-city-mini-2-city-mini-gt2/15103/219587,`,
                }
            ],
            targetExtension: 'csv',
        },
        {
            name: steps.EXTRACT_COMPATIBILITY_DATA,
            prompt: "extract compatibility data. Give the result in csv format. Format: first row; list of strollers, second row; list of seats, third row; adapter (just one cell).",
            source: 'ORIGIN',
            examples: [
                {
                    given: htmlPageExample,
                    then: `City Mini GT2
City GO,KeyFit,KeyFit 30,KeyFit 30 zip,Fit2
KeyFit adapter`,
                }
            ],
            targetExtension: 'csv',
        },
    ]
}

export default pipeline