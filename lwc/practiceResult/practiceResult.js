import { LightningElement,api,track } from 'lwc';
import practicesTitle from '@salesforce/label/c.SchoolConsultation_Title';
import fiscalCode from '@salesforce/label/c.SchoolConsultation_FiscalCode';
import practiceCodeIndicated from '@salesforce/label/c.SchoolConsultation_CaseNumber';
const PAGE_SIZE = 10; 


export default class PracticeResult extends LightningElement {
    @api practices;
    @api practicesString;
    @api currentpage;  
    @api pagesize;  
    @api totalpages;
    @api pageSize = 10;
    @api PaginationList;
    @api startPage;
    @api endPage;
    @api page = 1;  
    @api totalrecords;  
    @api _pagesize = PAGE_SIZE;  
    @api fiscalCode;
    @api practiceCodeIndicated;
    @track label = {
        practicesTitle,
        fiscalCode,
        practiceCodeIndicated
    }
    get pagesize() {  
      return this._pagesize;  
    }  
    set pagesize(value) {  
      this._pagesize = value;  
    }
    connectedCallback() {
        
        this.tributes = JSON.parse(this.practicesString);
        this.practices = this.tributes;
        this.pagination(this.tributes);
        this.handleFirst();
    }

    handlePrevious() {  
        if (this.page > 1) {  
          this.page = this.page - 1;  
        }
        var Paginationlist = [];
        var counter = 0;
        var start = this.startPage;
        for(var i= start-this._pagesize; i < start ; i++){
            if(i > -1){
                    Paginationlist.push(this.tributes[i]);
                counter ++;
            }else{
                start++;
            }
        }
        this.startPage = start - counter;
        this.endPage = this.endPage - counter;
        this.PaginationList = Paginationlist;
      }  
      handleNext() {  
        if (this.page < this.totalpages){
            this.page = this.page + 1;  
        }
        var Paginationlist = [];
        var counter = 0;
        for(var i = this.endPage + 1; i < this.endPage + this._pagesize + 1; i++){
            if(this.tributes.length > i){
                    Paginationlist.push(this.tributes[i]);
            }
            counter ++ ;
        }
        this.startPage = this.startPage + counter;
        this.endPage = this.endPage + counter;
        this.PaginationList = Paginationlist;
      }
      pagination(tributes) {
        var PaginationList = [];
        for(var i=0; i<this.pagesize; i++){
            if(this.totalrecords > i){
                PaginationList.push(tributes[i]);
            }
        }
        this.PaginationList = PaginationList;
      }  
      handleFirst() {  
        this.page = 1;
        var Paginationlist = [];
        var size = Math.min(this.tributes.length, this.pageSize);
        for(var i= 0; i < size ; i++){
            if(i > -1){
                    Paginationlist.push(this.tributes[i]);
            }
        }
        this.startPage = 0;
        this.endPage = this.pageSize-1;
        this.PaginationList = Paginationlist;
      }  
      handleLast() {  
        this.page = this.totalpages;
        var Paginationlist = [];
        for(var i= (this.totalpages-1) * this._pagesize; i < this.totalrecords ; i++){
            if(i > -1){
                    Paginationlist.push(this.tributes[i]);
            }
        }
        this.startPage = (this.totalpages-1) * this._pagesize;
        this.endPage = this.totalpages * this._pagesize-1;
        this.PaginationList = Paginationlist;  
      }  
}