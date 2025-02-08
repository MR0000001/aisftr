/**
* @author Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it
* @date Creation 21/08/2018
* @date Modification 05/04/2019 Marco Rosa - marco.rosa@nttdata.com
* @description XC_TR_Lead – Trigger on Lead
*/ 

trigger XC_TR_Lead on Lead (before insert, before update, before delete, after insert, after update, after delete) {
	XC_TR_Dispatcher.init(new XC_TR_Lead_Handler(), Trigger.operationType,Constants.MDT_SKIP_LEAD, 'SFM'); 	
}