import { LightningElement,api, track } from 'lwc';
const PAGE_SIZE = 10; 
import tributesTitle from '@salesforce/label/c.TributesConsultation_Title';
import fiscalCode from '@salesforce/label/c.SchoolConsultation_FiscalCode';
import positions from '@salesforce/label/c.TributesConsultation_Positions';
import year from '@salesforce/label/c.TributesConsultation_Year';
import tributeTypology from '@salesforce/label/c.TributesConsultation_TributeTypology';

export default class TributesResult extends LightningElement {
    @api tributes;
    @api tributesString;
    @api currentpage;  
    @api pagesize;  
    @api totalpages;
    @api showadditionalparameters = false;
    @api tributesYear;
    @api tributesTypology;
    @api pageSize = 10;
    @api PaginationList;
    @api startPage;
    @api endPage;
    @api page = 1;  
    @api totalrecords;  
    @api _pagesize = PAGE_SIZE;  
    @api fiscalCode;
    @api positions;
    @api year;
    @track label = {
        tributesTitle,
        fiscalCode,
        positions,
        year,
        tributeTypology
    }
    get pagesize() {  
      return this._pagesize;  
    }  
    set pagesize(value) {  
      this._pagesize = value;  
    }

    connectedCallback() {
        
        //this.tributes = JSON.parse(this.tributesString);
        var tempTributes = JSON.parse(this.tributesString)
        var tributes = [];
        for(var i=0; i<tempTributes.length; i++){
          var stringPayments = JSON.stringify(tempTributes[i].pagamentiPosizione);
          var payments;
          if(stringPayments != undefined){
            payments  = JSON.parse(stringPayments);
          }
          if(payments!= undefined && payments.length>0){
            for(var j=0; j<payments.length; j++){
              var tribute = Object.assign({},tempTributes[i]);
              tribute.importoPag = payments[j].importoPag;
              tribute.idPagamento = payments[j].idPagamento;
              tribute.dataPagamento = payments[j].dataPagamento;
              tribute.intermediarioPag = payments[j].intermediarioPag;
              tributes.push(tribute);
            }
        }else{
          tributes.push(tempTributes[i]);
        }
        }
        this.tributes = tributes;
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
        if (this.page < this.totalPages){
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
        this.page = this.totalPages;
        var Paginationlist = [];
        for(var i= (this.totalPages-1) * this._pagesize; i < this.totalrecords ; i++){
            if(i > -1){
                    Paginationlist.push(this.tributes[i]);
            }
        }
        this.startPage = (this.totalPages-1) * this._pagesize;
        this.endPage = this.totalPages * this._pagesize-1;
        this.PaginationList = Paginationlist;  
      }  

}