/**
 * The Class XC_TR_Lead_U_ConcatenatePhone.
 *
 * @author Simone Trenta - strenta@deloitte.it, Luca Tedeschi ltedeschi@deloitte.it
 * @date Creation 28/12/2018
 * @description Trigger Lead - XC_TR_Account_U_ConcatenatePhone Concatenate PhonePrefix and LeadPhone in Phone and MobilePrefix and LeadMobile in MobilePhone
 */ 

public class XC_TR_Lead_U_ConcatenatePhone {
    
     /**
      * @description Concatenate phone on insert.
      *
      * @param listNew the list new
      */
     public  static void concatenatePhoneOnInsert(List<Lead> listNew){
                 
        for(Lead l : listNew) {             
            if (!String.isBlank(l.XC_PhonePrefix__c) && !String.isBlank(l.XC_LeadPhone__c)){
            	l.Phone = '+' + l.XC_PhonePrefix__c.substringAfterLast('+') + l.XC_LeadPhone__c;
            }
            else{
                l.Phone = '';
              }
			if (!String.isBlank(l.XC_MobilePrefix__c) && !String.isBlank(l.XC_LeadMobile__c)){            
            	l.MobilePhone = '+' + l.XC_MobilePrefix__c.substringAfterLast('+') + l.XC_LeadMobile__c;
            }else{
                l.MobilePhone = '';
              }
        } 
    }
    
     /**
      * @description Concatenate phone on update.
      *
      * @param listNew the list new
      * @param mapOld the map old
      * @param mapNew the map new
      */
     public  static void concatenatePhoneOnUpdate(List<Lead> listNew, Map<id, Lead> mapOld, Map<id, Lead> mapNew){
         
        
            List<String> fieldToCheck = new List<String>{'XC_PhonePrefix__c', 'XC_LeadPhone__c', 'XC_MobilePrefix__c', 'XC_LeadMobile__c'};
            ListNew = XC_UTIL_Sobject.getListChanged(fieldToCheck, mapOld, mapNew);
        
       		ConcatenatePhoneOnInsert(ListNew);
         
    }

}