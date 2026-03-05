import { LightningElement, track } from 'lwc';
export default class Practice4 extends LightningElement {

    response = {
            "categories": [
                {
                "id": 1,
                "name": "Electronics",
                "products": [
                    {
                    "id": 101,
                    "name": "Smartphone",
                    "description": "Latest model smartphone with a 6.5-inch display.",
                    "price": 699,
                    "stockStatus": "In Stock",
                    "image": "https://www.shutterstock.com/image-photo/sun-sets-behind-mountain-ranges-600nw-2479236003.jpg",
                    "rating": 5,
                    "reviews": [
                        {
                        "user": "Rahul Sharma",
                        "rating": 5,
                        "comment": "Amazing phone, great value for money!"
                        }
                    ]
                    },
                    {
                    "id": 102,
                    "name": "Laptop",
                    "description": "A high-performance laptop with Intel i7 processor.",
                    "price": 999,
                    "stockStatus": "Out of Stock",
                    "image": "https://picsum.photos/200?random=1",
                    "rating": 3,
                    "reviews": [
                        {
                        "user": "Priya Verma",
                        "rating": 3,
                        "comment": "Decent laptop but a bit overpriced."
                        }
                    ]
                    }
                ]
                },
                {
                "id": 2,
                "name": "Clothing",
                "products": [
                    {
                    "id": 201,
                    "name": "T-shirt",
                    "description": "Comfortable cotton t-shirt available in various colors.",
                    "price": 25,
                    "stockStatus": "In Stock",
                    "image": "https://fastly.picsum.photos/id/215/200/200.jpg",
                    "rating": 3,
                    "reviews": [
                        {
                        "user": "Ankit Mehra",
                        "rating": 3,
                        "comment": "Good fit, but color faded after one wash."
                        }
                    ]
                    }
                ]
                },
                {
                "id": 3,
                "name": "Home Appliances",
                "products": [
                    {
                    "id": 301,
                    "name": "Air Conditioner",
                    "description": "Energy-efficient AC with smart controls.",
                    "price": 499,
                    "stockStatus": "In Stock",
                    "image": "Provide image URL for Air Conditioner here",
                    "rating": 4,
                    "reviews": [
                        {
                        "user": "Sneha Iyer",
                        "rating": 4,
                        "comment": "Cools the room quickly and operates quietly."
                        }
                    ]
                    }
                ]
                }
            ]
    }
    allProducts = [];
    filteredProducts = []
    @track isDetailToOpen = false;

    constructor(){
        super();
    }
    @track categoryOptions  = [];
    priceOption = [{label:'All',value:'All'},{label:'Low to High',value:'Low to High'},{label:'High to Low',value:'High to Low'}];
    ratingOption = [{label:'All',value:'All'},{label:'Low to High',value:'Low to High'},{label:'High to Low',value:'High to Low'}];
    selectedCat = 'All';
    selectedPrice = 'All';
    selectedRating = 'All';
    handleCategoryChange(event){
        this.selectedCat = event.detail.value;
        console.log("Selected vakl: ",this.selectedCat);
    
    }
    handlePriceChange(event){
        this.selectedPrice = event.detail.value;
        console.log("Selected vakl: ",this.selectedPrice);
    
    }
    handleRatingChange(event){
        this.selectedRating = event.detail.value;
        console.log("Selected vakl: ",this.selectedRating);
    
    }

    connectedCallback(){
        this.categoryOptions = [{label:'All', value:'All'}, ...this.response.categories.map(cat=>({label: cat.name, value:cat.name}))];
        this.allProducts = this.response.categories.flatMap(cat => cat.products.map(prod => ({...prod, category:cat.name})));
        this.filteredProducts = [...this.allProducts];
        console.log('All PRODDUCTS',this.allProducts);
    }
    applyFilter(){
        let data = [...this.allProducts];

        if(this.selectedCat!=='All'){
            data = data.filter(p => p.category===this.selectedCat);
        }
        if(this.selectedPrice==='Low to High'){
            data.sort((a,b)=> a.price - b.price);
        } else if(this.selectedPrice==='High to Low'){
            data.sort((a,b) => b.price-a.price);
        }

        if(this.selectedRating==='Low to High'){
            data.sort((a,b)=> a.rating - b.rating);
        } else if(this.selectedRating==='High to Low'){
            data.sort((a,b) => b.rating-a.rating);
        }
        this.filteredProducts = data;
    }
    viewDeatil(){
        this.isDetailToOpen = true;
    }
    handleCancelBtn(){
        this.isDetailToOpen = false;
    }


}