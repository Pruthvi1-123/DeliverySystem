// SPDX-License-Identifier: MIT
pragma solidity >0.4.0 <0.8.0;


// Menu Item and Restaurant  structure
contract FoodDeliverySystem {
    struct Restaurant {
        string name;
        address owner;
        mapping(uint256 => MenuItem) menu;
        uint256 menuCount;
    }

    struct MenuItem {
        string name;
        uint256 price;
    }
