/**
// dpalamides - 
* @date Creation 30/07/2020
* @date Modification 19/07/2020 dpalamides@deloitte.it
* @description Send ENEL X Material To Logistic process
*/
public without sharing class XC_LCC203_RMAExecution {
    /**
    * @author dpalamides - 
    * @date Creation 22/06/2020
    * @date Modification 19/07/2020 dpalamides@deloitte.it
    * @description // wrapper class with @AuraEnabled and {get;set;} properties 
    */
    public class ParamToGloviaSoli{
        /** @description param account to passa API create Sales Order Glovia */
        public String accountId;
        /** @description param product Id to pass API Glovia. */
        public String product2Id;
        /** @description The contract id. */
        public string unitPrice;
        /** @description The contract id. */
        public string quantity;
        /** @description The contract id. */
        public boolean ownedByEnelX;
        /** @description The contract id. */
        public String productRequiredId;
        /** @description The contract id. */

    }



    /*
  * @author dpalamides - 
  * @date Creation 22/06/2020
  * @date Modification 19/07/2020 dpalamides@deloitte.it
  * @description // wrapper class with @AuraEnabled and {get;set;} properties 
  */

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
        /** @description NE_OrderItem__c.XC_WBE__c on commercial item choose */
        @AuraEnabled
        public String wbeElement{get;set;}
        /** @description NE_OrderItem__c.XC_costCenter__c on commercial item choose  */
        @AuraEnabled
        public String costCenter{get;set;}
    }

    /*
  * @author dpalamides - 
  * @date Creation 22/06/2020
  * @date Modification 19/07/2020 dpalamides@deloitte.it
  * @description // wrapper class with @AuraEnabled and {get;set;} properties 
  */
    public class ParamToGloviaSO{
        /** @description The contract id. */
        public string accountId;
        /** @description The contract id. */
        public string fSLWorkOrder;
        /** @description The contract id. */
        public string warehouseId;
        /** @description The contract id. */
        public string shipToCity;
        /** @description The contract id. */
        public string shipToCountry;
        /** @description The contract id. */
        public string shipToStateProvince;
        /** @description The contract id. */
        public string shipToStreet;
        /** @description The contract id. */
        public string shipToZipPostalCode;
        /** @description The contract id. */
        public string fSLWorkOrderLineItem;
        /** @description The contract id. */
        public Datetime orderDate;
        /** @description The contract id. */
        public Boolean directPurchaseOrder;


    }

    /*
    * @author dpalamides - 
    * @date Creation 22/06/2020
    * @description // get Country ConfigurationItem 
    * @param workOrderLineItemId String
    * @return XC_NE_AddTechnicalItems_Controller.ResultAndMessage
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper createRMA(String workOrderLineItemId){

        List<WorkOrderLineItem> lstWOLI = (List<WorkOrderLineItem>) XC_UTIL_Sobject.selectAllFields(workOrderLineItemId);
        XC_UTIL_ResultWrapper rAndM = XC_UTIL_WOLICreateRMA.createRMAGlovia(lstWOLI);
        
        return rAndM;

    }



    /*
   * @author dpalamides - 
   * @date Creation 22/06/2020
   * @description // get Country ConfigurationItem 
   * @param fieldValue string
   * @param fieldName String
   * @param errorCheck boolean
   * @return string
   */

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

    /*
    * @author dpalamides/2020
    * @date Creation 01/08/2020 
    * @description mapListConfItemTechnicalMaterial
    * @param woliId string 
    * @return XC_NE_AddTechnicalItems_Controller.ResultAndMessage
    
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkAddPr(string woliId){
        XC_UTIL_ResultWrapper rAndM = new XC_UTIL_ResultWrapper();
        system.debug('@@@@ checkAddPr:' + woliId);
        rAndM.titleMessage = 'Add new Order material';
        rAndM.resultMessage = 'Order material added success!!';
        rAndM.typeMessage ='Success';
        rAndM.success = true;
        List<ProductRequired> prodRes = new List<ProductRequired>();
        prodRes = [select id from ProductRequired where parentRecordId =:woliId];
        system.debug('@@@@ checkAddPr - prodRes' + prodRes);
        if(prodRes.size()>0){
            rAndM.resultMessage = 'Order material is freeze, already sent!!';
            rAndM.typeMessage ='Error';
            rAndM.success = false;
            system.debug('@@@@ checkAddPr:' + rAndM.resultMessage);
            return rAndM;
        }else{
            return rAndM; }
    }




    /*
     * @author dpalamides - 
     * @date Creation 22/06/2020
     * @description // get Country ConfigurationItem 
     * @param woliId string
     * @return List<NE__OrderItem__c>
     */

    @AuraEnabled
    public static List<NE__OrderItem__c> getCommercialItemList(Id woliId){
        Id workOrderDec = [select WorkOrder.RootWorkOrderId from workOrderLineItem WHERE Id = :woliId].workorder.RootWorkOrderId;
        system.debug('@@@@ getCommercialItemList - workOrderDec:' + workOrderDec);
        List<WorkOrder> woChildDEC = new List<WorkOrder>();
        if(Schema.sObjectType.WorkOrder.isAccessible()){
            woChildDEC = [select id, XC_Configuration_Item__c from WorkOrder where RootWorkOrderId =:workOrderDec];
        }

        system.debug('@@@@ getCommercialItemList - woChildDEC:' + woChildDEC);
        List<String> idCommCIIds = new List<String>();
        if(woChildDEC.size()>0){
            for(WorkOrder wo: woChildDEC){
                system.debug('@@@@ getCommercialItemList - wo.XC_Configuration_Item__c:' + wo.XC_Configuration_Item__c);
                idCommCIIds.add(wo.XC_Configuration_Item__c);

            }
        }
        system.debug('@@@@ getCommercialItemList - idCommCIIds:' + idCommCIIds);
        List<NE__OrderItem__c> commercialCI = new List<NE__OrderItem__c>();
        if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            commercialCI=  [select Id, name from NE__OrderItem__c where id in:idCommCIIds];
        }
        system.debug('@@@@ getCommercialItemList - commercialCI:' + commercialCI);
        return commercialCI;

    }

    /*
      * @author dpalamides - 
      * @date Creation 22/06/2020
      * @description // get Country ConfigurationItem 
      * @param confItemComm id
      * @return LParamToGloviaSoli
      */

    @AuraEnabled
    public static ResultOtherPA getParamToGlovia(Id confItemComm){

        ResultOtherPA  param = new ResultOtherPA();
        param.result = false;
        system.debug('@@@@ getParamToGlovia - confItemComm:' + confItemComm);
        List<NE__OrderItem__c> confComm = new List<NE__OrderItem__c>();
        if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            confComm=[SELECT XC_WBE__c, XC_CMCostCenter__c from NE__OrderItem__c where id=:confItemComm];
            system.debug('@@@@ getParamToGlovia - conComm:' + confComm);

            for(NE__OrderItem__c ci : confComm){
                param.costCenter = ci.XC_CMCostCenter__c;
                param.wbeElement = ci.XC_WBE__c;
                system.debug('@@@@ getParamToGlovia - param.costCenter:' + param.costCenter);
                system.debug('@@@@ getParamToGlovia - param.wbeElement:' + param.wbeElement);

                if(ci.XC_WBE__c =='' && ci.XC_CMCostCenter__c ==''){

                    param.result = false;
                    param.message ='Operation failed!!! WBE element or costCenter missing';
                    param.titleMessage = 'Order Material';
                    param.typeMessage = 'Error';

                }else

                        param.result = true;


            }
            system.debug('@@@@ getParamToGlovia - param.result:' + param.result);
        }

        return param;
    }




}