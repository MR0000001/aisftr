/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/08/2018
* @date Modification dd/mm/yyyy
* @description XC_TR_ContentDocumentLink – Trigger on ContentDocumentLink
*/ 

trigger XC_TR_ContentDocumentLink on ContentDocumentLink (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_ContentDocumentLink_Handler(), Trigger.operationType); 	
}