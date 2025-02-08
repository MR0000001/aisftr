/**
* @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
* @date Creation 06/11/2018
* @date Modification dd/mm/yyyy
* @description XC_TR_AssetItemAttribute - Trigger on AssetItemAttribute
*/ 

trigger XC_TR_AssetItemAttribute on NE__AssetItemAttribute__c (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_AssetItemAttribute_Handler(), Trigger.operationType); 	
}