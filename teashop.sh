#!/bin/bash

# View Products
view_products() {
    echo "-----------------------------"
    echo "ID | Name | Price | Stock"
    echo "-----------------------------"
    cat products.txt
    echo "-----------------------------"
}

# Dashboard
dashboard() {
    total_products=$(cat products.txt | wc -l)
    total_sales=$(awk -F'|' '{sum+=$3} END {print sum}' bills.txt)

    echo "------ DASHBOARD ------" 
    echo "Total Products : $total_products" >> dash.txt
    echo "Total Sales    : Rs.$total_sales" >> dash.txt

    cat dash.txt
}

# Low Stock Alert
low_stock() {
    echo "------ LOW STOCK ------" 
    awk -F'|' '$4 < 10 {print $2 " stock is low: " $4}' products.txt >> lowstock.txt

    cat lowstock.txt
}

# Daily Sales
daily_sales() {
    today=$(date +%d)

    echo "------ TODAY SALES ------"
    grep "^$today|" bills.txt >> dailysale.txt

    cat dailysale.txt
}

# Top Sales
top_sales() {
    echo "------ TOP SALES ------"
    cut -d'|' -f2 bill_items.txt | sort | uniq -c | sort -nr >> topsale.txt

    cat topsale.txt
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

        product=$(grep "^$pid|" products.txt)

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
        sed -i "s/^$pid|$name|$price|$stock/$pid|$name|$price|$new_stock/" products.txt

        # Save bill item (Human Format)
        echo "Date : $bill_id | Product : $name | Qty : $qty | Amount : Rs.$amount" >> bill_items.txt

        echo "Added -> $name * $qty = Rs.$amount"
    done

    # Save final bill (Human Format)
    echo "$bill_id|$name|$total" >> bills.txt

    echo "------ FINAL BILL ------"
    grep "Date : $bill_id" bill_items.txt
    echo "Total Bill: Rs.$total"
}

# Restore Stock
restore_stock() {
    read -p "Enter Product ID: " pid

    product=$(grep "^$pid|" products.txt)

    if [ -z "$product" ]; then
        echo "Invalid Product ID!"
        return
    fi

    name=$(echo "$product" | cut -d'|' -f2 | xargs)
    price=$(echo "$product" | cut -d'|' -f3 | xargs)
    stock=$(echo "$product" | cut -d'|' -f4 | xargs)

    read -p "Enter Stock to Add: " add_stock

    new_stock=$(( stock + add_stock ))

    sed -i "s/^$pid|$name|$price|$stock/$pid|$name|$price|$new_stock/" products.txt

    echo "$name stock updated successfully!"
    echo "New Stock: $new_stock"
}

# Main Menu
while true
do
    echo ""
    echo "========= TEA SHOP ========="
    echo "1. Dashboard"
    echo "2. View Products"
    echo "3. Your Order"
    echo "4. Low Stock"
    echo "5. Daily Sales"
    echo "6. Top Sales"
    echo "7. Restore Stock"
    echo "8. Exit"
    echo "============================"

    read -p "Choose Option: " choice

    case $choice in
        1) dashboard ;;
        2) view_products ;;
        3) Your_order ;;
        4) low_stock ;;
        5) daily_sales ;;
        6) top_sales ;;
        7) restore_stock ;;
        8) exit ;;
        *) echo "Invalid Option" ;;
    esac
done 
