import { LightningElement, api, track } from 'lwc';  
import firstPage from '@salesforce/label/c.KMSearch_First';
import previousPage from '@salesforce/label/c.KMSearch_Previous';
import nextPage from '@salesforce/label/c.KMSearch_Next';
import lastPage from '@salesforce/label/c.KMSearch_Last';
export default class PaginatorBottom extends LightningElement {  
  // Api considered as a reactive public property.  
  @api totalrecords;  
  @api currentpage;  
  @api pagesize;
  @track label = {
		previousPage,
		firstPage,
		nextPage,
    lastPage
    };
  // Following are the private properties to a class.  
  lastpage = false;  
  firstpage = false;  
  // getter  
  get showFirstButton() {
    if (this.currentpage === 1 || this.currentpage === 0) {  
      return true;  
    }  
    return false;  
  }  
  // getter  
  get showLastButton() {  
    if (Math.ceil(this.totalrecords / this.pagesize) === this.currentpage) {  
      return true;  
    }  
    return false;  
  }  
  //Fire events based on the button actions  
  handlePrevious() {  
    this.dispatchEvent(new CustomEvent('previous'));  
  }  
  handleNext() {  
    this.dispatchEvent(new CustomEvent('next'));  
  }  
  handleFirst() {  
    this.dispatchEvent(new CustomEvent('first'));  
  }  
  handleLast() {  
    this.dispatchEvent(new CustomEvent('last'));  
  }  
}