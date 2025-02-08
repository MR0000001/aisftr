/**
* @author FirstName : Rishabh Bansal
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description Giic_IntegrationWrapper – Wrapper class for Integration Api's   
*/ 
public without sharing class Giic_IntegrationWrapper {       
   
    /**
* @author FirstName : Rishabh Bansal
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy 
* @description TOReceipt – Wrapper class for Integration Api's
*/  
    Public class TOReceipt {
         private final  Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_IntegrationWrapper');
        /**
        * @description transferOrderID- for Transfer Order Receipt
        */
        Public String transferOrderID {get;set;}
         /**
        * @description receiptDate- for Transfer Order Receipt
        */
        Public Date receiptDate {get;set;}
         /**
        * @description integrationOperation- for Transfer Order Receipt
        */
        Public String integrationOperation {get;set;}
        /**
        * @description targetSystem- for Transfer Order Receipt
        */
        Public String targetSystem {get;set;}
         /**
        * @description toReceiptLine- for Transfer Order Receipt
        */
        Public List<TOReceipetLine> toReceiptLine {get;set;}
    }
      /**
* @author FirstName : Rishabh Bansal
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description TOReceipetLine – Wrapper class for Integration Api's
*/ 
    Public class TOReceipetLine {
          /**
        * @description toLineID- for Transfer Order Receipt
        */
         Public String toLineID {get;set;}
           /**
        * @description location- for Transfer Order Receipt     
        */
         Public ID location {get;set;}
    }
      /**
* @author FirstName : Rishabh Bansal
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description TOReceiptResponse – Wrapper class for Integration Api's
*/ 
    Public class TOReceiptResponse {
           /**
        * @description isSuccess- for Transfer Order Receipt
        */
        Public Boolean isSuccess {get;set;}
          /**
        * @description location- for Transfer Order Receipt
        */
        Public ID location {get;set;}
        /**
        * @description errorList- for Transfer Order Receipt
        */
        Public List<ErrorList> errorList {get;set;}
    }
        /**
* @author FirstName : Rishabh Bansal
* @date Creation 22/08/2019
* @date Modification dd/mm/yyyy
* @description ErrorList – Wrapper class for Integration Api's
*/ 
    Public class ErrorList {
        /**
        * @description errorMsg- for Transfer Order Receipt
        */
        Public String errorMsg {get;set;}
    }
}