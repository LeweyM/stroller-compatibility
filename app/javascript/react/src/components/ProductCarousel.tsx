import React from "react";
import Slider, {CustomArrowProps} from "react-slick";
import {Product} from "../types/product";

const PURPLE_800_COLOR = "#6b21a8";

function SampleArrow(props: CustomArrowProps) {
    const {className, style, onClick} = props;
    return (
        <div
            className={className}
            style={{...style, color: PURPLE_800_COLOR, display: "block"}}
            onClick={onClick}
        />
    );
}


type Props = {
    items: Product[]
};

function MultipleItems({items}: Props) {
    const showItems = (n: number) => Math.min(items.length, n);
    const responsive = [
        {
            breakpoint: 1024,
            settings: {
                slidesToShow: showItems(3),
                slidesToScroll: showItems(3),
                dots: true
            }
        },
        {
            breakpoint: 600,
            settings: {
                slidesToShow: showItems(2),
                slidesToScroll: showItems(2),
            }
        },
        {
            breakpoint: 480,
            settings: {
                slidesToShow: showItems(1),
                slidesToScroll: showItems(1)
            }
        }
    ];
    const settings = {
        dots: true,
        arrows: true,
        speed: 500,
        infinite: false,
        slidesToShow: showItems(3),
        slidesToScroll: showItems(3),
        nextArrow: <SampleArrow/>,
        prevArrow: <SampleArrow/>,
        responsive,
    };
    return (
        <div className="slider-container">
            <Slider {...settings}>
                {items.map((item, index) => (
                    <div key={index}>
                        <div className={"flex flex-col items-center justify-center p-2"}>
                            <img className={"w-52 h-52 object-scale-down"} src={item.image.url} alt={item.image.alt_text}/>
                            <a href={item.url}>
                                <p>{item.name}</p>
                            </a>
                            <p className={"text-gray-400"}>By {item.brand_name}</p>
                        </div>
                    </div>
                ))}
            </Slider>
        </div>
    );
}

export default MultipleItems;