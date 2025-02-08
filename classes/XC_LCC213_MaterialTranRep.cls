public without sharing class XC_LCC213_MaterialTranRep {


    public class ParamToGlovia{
		
        public String productCode;
        public Decimal price;
        public String inCurrency;
        
	}
	
	
	 public class ResultOtherPA{ 
       /** @description result operation */
        @AuraEnabled
        public boolean result{get;set;}
          /** @description message operation */
        @AuraEnabled
        public String message{get;set;}
          /** @description type message operation success/error */
        @AuraEnabled
        public String typeMessage{get;set;}
           /** @description title modal message */
        @AuraEnabled
        public String titleMessage{get;set;}
		
	}
	
	
	@AuraEnabled
    public static XC_UTIL_ResultWrapper createMTR(String workOrderLineItemId){

        List<WorkOrderLineItem> lstWOLI = (List<WorkOrderLineItem>) XC_UTIL_Sobject.selectAllFields(workOrderLineItemId);
        XC_UTIL_ResultWrapper rAndM = XC_UTIL_WOLICreateMatTranRep.createMTR(lstWOLI);
        
        return rAndM;

    }
	
	public static string chechMandatoryField(string fieldValue, string fieldName, boolean errorCheck){
        system.debug('@@@@ chechMandatoryField - fieldValue:' + fieldValue);
        system.debug('@@@@ chechMandatoryField - fieldName:' + fieldName);
        system.debug('@@@@ chechMandatoryField - errorChecj:' + errorCheck);
        string message='';
        if(fieldValue =='' || fieldvalue == null){
            message = message + 'failed, missing ' + fieldName + ' Reference!';
            errorCheck = true;
        }
        system.debug('@@@@ chechMandatoryField - message:' + message);
        return message;
    }
	
	
	
	@AuraEnabled
    public static XC_UTIL_ResultWrapper checkAddPr(string woliId){
        XC_UTIL_ResultWrapper mTR = new XC_UTIL_ResultWrapper();
        system.debug('@@@@ checkAddPr:' + woliId);
        mTR.titleMessage = 'Add new Order material';
        mTR.resultMessage = 'Order material added success!!';
        mTR.typeMessage ='Success';
        mTR.success = true;
        List<ProductRequired> prodRes = new List<ProductRequired>();
        prodRes = [select id from ProductRequired where parentRecordId =:woliId];
        system.debug('@@@@ checkAddPr - prodRes' + prodRes);
        if(prodRes.size()>0){
            mTR.resultMessage = 'Order material is freeze, already sent!!';
            mTR.typeMessage ='Error';
            mTR.success = false;
            system.debug('@@@@ checkAddPr:' + mTR.resultMessage);
            return mTR;
        }else{
            return mTR; }
    }
	
}