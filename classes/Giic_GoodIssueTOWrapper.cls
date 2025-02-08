/**
* @author Anil Giri - Anil.giri@in.fujitsu.com
* @date Creation 08/08/2019
* @description - Wrapper classes used in Giic_GoodIssueTO, it is also used for API
*/

public without sharing class Giic_GoodIssueTOWrapper {
    
	@AuraEnabled public string transferOrderID;
	@AuraEnabled public string reference;
    @AuraEnabled public map<string,Integer> maplotNameToQuantity = new map<string,Integer>();  //new
	@AuraEnabled public date dateDelivery;
	@AuraEnabled public date registrationDate;
    @AuraEnabled public string externalSystemID;
    @AuraEnabled public List<Giic_GoodIssueTOLineWrapper> lstOrderLine;

    /** @description Giic_GoodIssueTOWrapper constructor */
    public Giic_GoodIssueTOWrapper() {
        this.transferOrderID = '';
        this.externalSystemID = '';
        this.reference = '';
        this.dateDelivery = null;
        this.registrationDate = null;
        this.lstOrderLine = new List<Giic_GoodIssueTOLineWrapper>();
    }

    /**  @description - Giic_GoodIssueTOLineWrapper */   
    public class Giic_GoodIssueTOLineWrapper{
        @AuraEnabled public string productName;
        @AuraEnabled public string eanCode;
        @AuraEnabled public string productCode;
        @AuraEnabled public string SKUCode;  // new NR0740
        @AuraEnabled public boolean isSerialCntr;
        @AuraEnabled public boolean isLotControlled;  //new
        @AuraEnabled public decimal orderQuantity;
        @AuraEnabled public string transferOrderLine;
        @AuraEnabled public string transferOrderLineName;
        @AuraEnabled public string locationId;//Added new 
        @AuraEnabled public string locationName;//Added new 
        @AuraEnabled public string transferToWarehouse;     
        @AuraEnabled public string transferFromWarehouseId;    
        @AuraEnabled public string exSysLineid;
        @AuraEnabled public List<Giic_AssignedSerialWrapper> lstAssignedSerial;
        @AuraEnabled public List<Giic_AssignedLotWrapper> lstAssignedLot;

        /** @description - Giic_GoodIssueTOLineWrapper constructor */
        public Giic_GoodIssueTOLineWrapper(){
            this.eanCode='';
            this.productName='';
            this.isSerialCntr = false;
            this.orderQuantity = 0.0;
            this.transferOrderLine = '';
            this.transferOrderLineName = '';
            this.locationId = '';
            this.locationName = '';
            this.transferToWarehouse = '';
            this.exSysLineid='';
            this.lstAssignedSerial = new List<Giic_AssignedSerialWrapper>();
            this.lstAssignedLot = new List<Giic_AssignedLotWrapper>();
        }
    }

    /**  @description - Giic_AssignedSerialWrapper */
    public class Giic_AssignedSerialWrapper{
        @AuraEnabled public string serialNumber;

        /** @description - Giic_AssignedSerialWrapper */
        public Giic_AssignedSerialWrapper(){
            this.serialNumber = '';
        }
    }
    
    /** @description Giic_AssignedLotWrapper */
    public class Giic_AssignedLotWrapper{
        @AuraEnabled public string lotNumber;
        @AuraEnabled public integer lotQty;
        
        /** @description Giic_AssignedLotWrapper */
        public Giic_AssignedLotWrapper(){
            this.lotNumber = '';
            this.lotQty = 0;
        }
    }

}