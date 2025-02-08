/*
 *
 * @author Nicola Arrigo - narrigo@deloitte.it
 * @date Creation 11/12/2019
 * @description XC_Util_ActionPlanTemplate  Evaluate the duplication checks for Action Plan creation based on string name_LegalEntity of the Action Plan Template record
 */

public with sharing class XC_Util_ActionPlanTemplate {
    /**
     * @author Nicola Arrigo - narrigo@deloitte.it
     * @param newMapApt map <id,ActionPlanTemplate__c>
     * @param oldMapApt map <id,ActionPlanTemplate__c>
     * @description - it is used to check duplicate records for Action Plan Template object
     */  
    public class MyWrapper{
      public boolean success{get;set;}
      public string message{get;set;}

      public MyWrapper(boolean success,string message){
          this.success=success;
          this.message=message;
      }
    }
    public List<MyWrapper> wrapperList{get;set;}
    public static List<MyWrapper> checkDuplicate(ActionPlanTemplate__c apt){     
       // list<ActionPlanTemplate__c> listActionPlanTemplatetoCheck= new list<ActionPlanTemplate__c>();
      /*  for(ActionPlanTemplate__c ap:newMapApt.values()){
            if(ap.XC_LegalEntity__c!=null &&
                newMapApt.get(ap.id).XC_LegalEntity__c!=oldMapApt.get(ap.id).XC_LegalEntity__c){
                //listActionPlanTemplatetoCheck.add(listActionPlanTemplatetoCheck);
                 //listKeyValues is a list of string to concatenate the Name and Legal Entity of the Action Plan Template record
                // list<string> listKeyValues=new list<string>();
                 string [] listLegalEntity=ap.XC_LegalEntity__c.split(';');
                 boolean trovato=false;
                 for(string le:listLegalEntity){
                   system.debug('legal entity'+' '+le);
                    system.debug('string id'+' '+ap.name+'_'+le);
                    if(listKeyOldValues.contains(ap.name+'_'+le)){
                       trovato=true;
                      system.debug('Legal Entity value'+' '+le);
                      system.debug('Duplicate value found');
                       string errorMessage=le+' '+Label.XC_CL_ActionPlanTemplateErrorMessage;
					   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage);
                       ApexPages.addMessage(myMsg);                       
					//   ap.addError(le+' '+Label.XC_CL_ActionPlanTemplateErrorMessage);
                    }
                   if(trovato==true){
                      break;
                   }
                   // listKeyValues.add(ap.name+'_'+ap.XC_LegalEntity__c);
                 }                    
               }                         
        }*/
		system.debug('@@@@ START checkDuplicates');
        //Boolean to define if there are duplicates
        boolean success=true;
        //string to take an error message
        string message;
        //Wrapper List
        List<MyWrapper> wrapperList=new List<MyWrapper>();
        //List of existing records
        List<ActionPlanTemplate__c> existedRecords=existedRecords(apt.id);
        list<string> listKeyExixstedRecords=listKeyExixstedRecords(existedRecords);
		string [] listLegalEntity=apt.XC_LegalEntity__c.split(';');
		boolean trovato=false;
        for(string le:listLegalEntity){
		system.debug('legal entity'+' '+le);
        system.debug('string KeyValue'+' '+apt.name+'_'+le);
		if(listKeyExixstedRecords.contains(apt.name+'_'+le)){
        trovato=true;
        success=false;
        system.debug('Legal Entity value'+' '+le);
        system.debug('Duplicate value found');
       string errorMessage=le+' '+Label.XC_CL_ActionPlanTemplateErrorMessage;
	    message=errorMessage;
         if(trovato=true){
             break;
           }                    
         }
		
        }
    wrapperList.add(new MyWrapper(success,message));
    system.debug('wrapperList-->'+wrapperList);
    return wrapperList;
    }
        /**
     * @author Nicola Arrigo - narrigo@deloitte.it
     * @param listActionPlanTemplateExisting list<ActionPlanTemplate__c>
     * @description 
     */
    public static list<string> listKeyExixstedRecords( list<ActionPlanTemplate__c> listActionPlanTemplateExisting){
       list<string> listKeyOldValues=new list<string>();
        for(ActionPlanTemplate__c ap:listActionPlanTemplateExisting){
           if(ap.XC_LegalEntity__c!=null){
               string [] listLegalEntity=ap.XC_LegalEntity__c.split(';');
               for(string le:listLegalEntity){
                    listKeyOldValues.add(ap.name+'_'+le);
                 }
           }
        }
        system.debug('List key Old Values'+' '+listKeyOldValues);
        return listKeyOldValues;
    }
    public static List<ActionPlanTemplate__c> existedRecords(id aptId){
        List<ActionPlanTemplate__c> existedRecords=[select id,name,XC_LegalEntity__c from ActionPlanTemplate__c
                                                    where id!=:aptId ];
        return existedRecords;    
    }

}