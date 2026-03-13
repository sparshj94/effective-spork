import { LightningElement, wire, track } from 'lwc';
import getProducts from '@salesforce/apex/ProductAndPriceController.getProductsAndPrice';

export default class EcommerceApp extends LightningElement {
    productData = [];
    @track cartArray = [];

    @wire(getProducts)
    getProductData({error, data}){
        if(data){
            this.productData = data;
        } else if (error) {
            console.error('Error fetching products:', error);
        }
    }

    // Point 4: Indicate current number of items
    get totalCartItems() {
        return this.cartArray.reduce((total, item) => total + item.Quantity, 0);
    }

    // Point 8: Display total price of all items
    get cartTotalPrice() {
        return this.cartArray.reduce((total, item) => total + (item.Quantity * item.UnitPrice), 0);
    }

    // Point 2: Add to Cart & Increase Quantity
    handleAddProduct(event){
        const prodId = event.target.dataset.productId;
        const prodName = event.target.dataset.productName;
        // We pull the price from the dataset so we can calculate totals later
        const unitPrice = parseFloat(event.target.dataset.productPrice); 

        // Check if the product is already in the cart
        const existingItemIndex = this.cartArray.findIndex(item => item.Id === prodId);

        if (existingItemIndex !== -1) {
            // It exists, so just increase the quantity
            this.cartArray[existingItemIndex].Quantity += 1;
        } else {
            // It doesn't exist, push a new object into the array
            this.cartArray.push({
                Id: prodId,
                Name: prodName,
                Quantity: 1,
                UnitPrice: unitPrice
            });
        }
    }

    // Point 6: Update Quantity from within the cart
    handleQuantityUpdate(event) {
        const action = event.target.dataset.action; // 'increase' or 'decrease'
        const prodId = event.target.dataset.productId;
        
        const itemIndex = this.cartArray.findIndex(item => item.Id === prodId);

        if (itemIndex !== -1) {
            if (action === 'increase') {
                this.cartArray[itemIndex].Quantity += 1;
            } else if (action === 'decrease') {
                this.cartArray[itemIndex].Quantity -= 1;
                
                // If quantity hits 0, remove it from the cart entirely
                if (this.cartArray[itemIndex].Quantity === 0) {
                    this.cartArray.splice(itemIndex, 1);
                }
            }
        }
    }

    // Point 7: Remove item completely
    removeItemCart(event){
        const prodId = event.target.dataset.productId;
        
        // FIX: Reassign to this.cartArray to trigger UI update. 
        // Notice there are no curly braces after the arrow, so it implicitly returns the evaluation.
        this.cartArray = this.cartArray.filter(el => el.Id !== prodId);
    }

    // Point 9 Placeholder
    handleCheckout() {
        console.log('Ready to checkout with these items:', JSON.stringify(this.cartArray));
        console.log('Total Price:', this.cartTotalPrice);
        // Here you will call an Apex method to create the Opportunity and OpportunityLineItems
    }
}