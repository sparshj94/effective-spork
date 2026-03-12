import { LightningElement, wire, track } from 'lwc';
import getProducts from '@salesforce/apex/ProductAndPriceController.getProductsAndPrice'
export default class EcommerceApp extends LightningElement {


    
    productData = [];
    @track cartArray = [];
    isToPush = false;
    @wire(getProducts)
    getProductData({error, data}){
        if(data){
            this.productData = data;
            console.log(data);
            
        }
    }

    handleAddProduct(event){
        let prodExists = false;
        const prodId = event.target.dataset.productId
        console.log(prodId);
        console.log(this.cartArray);
        // console.log(this.cartArray);
        
        const prodName = event.target.dataset.productName
        
        if(this.cartArray.length<1){
            console.log('l<0');
            this.cartArray.push({Id:prodId,Name:prodName,Quantity:1});
        }else{
            console.log('else');
            
            this.cartArray.forEach(el=>{
                console.log(el.Id + ' ' + prodId);
                
                if(el.Id===prodId){
                    el.Quantity+=1;
                    prodExists = true;
                } else{
                    console.log('push');
                    //this.cartArray.push({Id:prodId,Name:prodName,Quantity:1})
                }
            })
            if(!prodExists){
                this.cartArray.push({Id:prodId,Name:prodName,Quantity:1})
            }
            
            
            
        }
        
    }
    removeItemCart(event){
        const prodId = event.target.dataset.productId
        console.log(prodId);
        
        const dataa = this.cartArray.filter((el)=>{
            el.Id !==prodId
        })
        console.log(dataa.length);
    }



}