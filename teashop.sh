#!/bin/bash

view_products() {
    cat products.txt
}

Your_order() {
    total=0
    bill_id=$(date +%y)

    while true
    do
        read -p "Enter Product ID (0 to stop): " pid

        if [ "$pid" -eq 0 ]; then
            break
        fi

        product=$(grep "^$pid " products.txt)

        if [ -z "$product" ]; then
            echo "Invalid Product ID!"
            continue
        fi

        name=$(echo "$product" | cut -d'|' -f2 | xargs)
        price=$(echo "$product" | cut -d'|' -f3 | xargs)

        read -p "Enter Quantity: " qty

        amount=$(( price * qty ))
        total=$(( total + amount ))

        echo "$bill_id|$name|$qty|$amount" >> bill_items.txt

        echo "Added -> $name * $qty = Rs.$amount"
    done

    echo "$bill_id|$name|$total" >> bills.txt

    echo "------ FINAL BILL ------"
    grep "^$bill_id|" bill_items.txt
    echo "Total Bill: Rs.$total"
}

while true
do
    echo "TEA SHOP"

    echo "1. View Products"
    echo "2. Your Order"
    echo "3. Exit"

    read -p "Choose Option: " choice

    case $choice in
        1) view_products ;;
        2) Your_order ;;
        3) exit ;;
        *) echo "Invalid Option" ;;
    esac
done
