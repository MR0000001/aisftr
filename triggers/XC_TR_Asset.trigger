/**
* @author Giulio Serra -giserra@deloitte.it
* @date Creation 03/10/2018
* @date Modification 08/04/2019 Marco Rosa - marco.rosa@nttdata.com
* @description XC_TR_Asset – Trigger on Asset
*/ 

trigger XC_TR_Asset on Asset (before insert, before update, before delete, after insert, after update, after delete){
    XC_TR_Dispatcher.init(new XC_TR_Asset_Handler(), Trigger.operationType,Constants.MDT_SKIP_ASSET); 	
}