#!/bin/bash

BI=/home/killer/demo/BillingSystem/master/bill_items.txt
PD=/home/killer/demo/BillingSystem/master/products.txt

# View Products
view_products() {
    echo "-----------------------------"
    echo "ID | Name | Price | Stock"
    echo "-----------------------------"
    cat $PD
    echo "-----------------------------"
}

# Order Function
Your_order() {
    total=0
    bill_id=$(date +%d)

    while true
    do
        read -p "Enter Product ID (0 to stop): " pid

        if [ "$pid" -eq 0 ]; then
            break
        fi

        product=$(grep "^$pid|" $PD)

        if [ -z "$product" ]; then
            echo "Invalid Product ID!"
            continue
        fi

        name=$(echo "$product" | cut -d'|' -f2 | xargs)
        price=$(echo "$product" | cut -d'|' -f3 | xargs)
        stock=$(echo "$product" | cut -d'|' -f4 | xargs)

        read -p "Enter Quantity: " qty

        if [ "$qty" -gt "$stock" ]; then
            echo "Stock not available!"
            continue
        fi

        new_stock=$(( stock - qty ))
        amount=$(( price * qty ))
        total=$(( total + amount ))

# Update stock
        sed -i "s/^$pid|$name|$price|$stock/$pid|$name|$price|$new_stock/" $PD

# Save bill
        echo "Date : $bill_id | Product : $name | Qty : $qty | Amount : Rs.$amount" >> $BI

        echo "Added -> $name * $qty = Rs.$amount"
    done

# Total Bill

Total_Bill() {

    echo "------ FINAL BILL ------"
    grep "Date : $bill_id" $BI
    echo "Total Bill: Rs.$total"
}

}


# Main Menu
while true
do
    echo ""
    echo "========= TEA SHOP ========="
    echo "1. View Menu"
    echo "2. Your Order"
    echo "3. Total Bill"
    echo "4. Exit"
    echo "============================"

    read -p "Choose Option: " choice

    case $choice in
        1) view_products ;;
        2) Your_order ;;
        3) Total_Bill ;;
        4) exit ;;
        *) echo "Invalid Option , you have options 1 , 2 , 3" ;;
    esac
done 
