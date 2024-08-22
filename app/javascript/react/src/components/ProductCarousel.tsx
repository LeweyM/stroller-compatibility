import React from "react";
import Slider, {CustomArrowProps} from "react-slick";
import {Product} from "../types/product";

const PURPLE_800_COLOR = "#6b21a8";
function SampleArrow(props: CustomArrowProps) {
    const { className, style, onClick } = props;
    return (
        <div
            className={className}
            style={{ ...style, color: PURPLE_800_COLOR, display: "block" }}
            onClick={onClick}
        />
    );
}

const responsive = [
    {
        breakpoint: 1024,
        settings: {
            slidesToShow: 3,
            slidesToScroll: 3,
            dots: true
        }
    },
    {
        breakpoint: 600,
        settings: {
            slidesToShow: 2,
            slidesToScroll: 2,
            initialSlide: 2
        }
    },
    {
        breakpoint: 480,
        settings: {
            slidesToShow: 1,
            slidesToScroll: 1
        }
    }
];

type Props = {
    items: Product[]
};
function MultipleItems({items}: Props) {
    console.log(items)
    const settings = {
        dots: true,
        arrows: true,
        speed: 500,
        slidesToShow: 3,
        slidesToScroll: 3,
        nextArrow: <SampleArrow />,
        prevArrow: <SampleArrow />,
        responsive,
    };
    return (
        <div className="slider-container">
            <Slider {...settings}>
                {items.map((item, index) => (
                    <div key={index}>
                        <img className={"w-52 h-52 object-scale-down"} src={item.image_url} alt={item.name}/>
                        <a href={item.url}>
                            <p>{item.name}</p>
                        </a>
                        <p className={"text-gray-400"}>By {item.brand_name}</p>
                    </div>
                ))}
            </Slider>
        </div>
    );
}

export default MultipleItems;