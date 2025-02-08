/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 22/06/2020
* @description XC_TR_Opportunity_U_CreditCheck 
*/  
public with sharing class XC_CaseClosure_CreditCheck {
   /**
     * @author Nicola Arrigo
     * @@date Creation 2/06/2020
     * @description Method to check CreditCheck
     * @param mapNew - Map<Id,Case>
     * @param mapOld - Map<Id,Case>
    **/
  public static void caseClosure(Map<Id,Case> mapNew,Map<Id,Case> mapOld){
    system.debug('caseClosure method'); 
    List<Id> oppListIdOk=new List<id>();
      List<Id> oppListIdKo=new List<id>();
      List<Id> oppListIdOKprepayment=new List<id>();
      List<Id> oppListIdOKconditioned=new List<id>();

      for(case c:mapNew.values()){
        if( c.Status!=mapOld.get(c.id).Status && 
            c.Status=='ESTA007' &&
            c.Reason=='XCMOT007' &&
            c.SubCause__c=='ATCL157' &&
            c.XC_Subtype__c=='XC192' &&
                c.XC_Result__c == 'RS003'
           ){
            if(c.XC_Resolution__c == 'R135'){
                oppListIdOk.add(c.XC_Opportunity__c);
            }else if (c.XC_Resolution__c=='R136'){
                oppListIdKo.add(c.XC_Opportunity__c);
            }else if (c.XC_Resolution__c=='R162'){
                oppListIdOKprepayment.add(c.XC_Opportunity__c);             
            }else if(c.XC_Resolution__c=='R163'){
                oppListIdOKconditioned.add(c.XC_Opportunity__c);
            }

            /*
              if(c.XC_Resolution__c=='R135' &&
                 c.XC_Result__c=='RS003'){
                  oppListIdOk.add(c.XC_Opportunity__c);
                 }else if(c.XC_Resolution__c=='R136' &&
                                  c.XC_Result__c=='RS003'){
                                  oppListIdKo.add(c.XC_Opportunity__c); 
                    }*/
           }
      }
      string creditCheck;
      List<Opportunity> oppList=new List<Opportunity>();
      if(oppListIdOk.size()>0){
        creditCheck='OK';
        oppList=retrieveOpp(oppListIdOk);
        system.debug('creditCheck'+' '+creditCheck);
        sendEmail(oppList, mapNew, 'R135');
        updateOpp(oppList,creditCheck);
      } 
      if (oppListIdKo.size()>0){
         creditCheck='KO';
         oppList=retrieveOpp(oppListIdKo);
         system.debug('creditCheck'+' '+creditCheck);
         sendEmail(oppList, mapNew, 'R136');
         updateOpp(oppList,creditCheck);
      }


      if (oppListIdOKprepayment.size()>0){
          creditCheck='OK_prepayment';

          oppList=retrieveOpp(oppListIdOKprepayment);
       
          sendEmail(oppList, mapNew, 'R162');

          updateOpp(oppList,creditCheck);
      }
      if (oppListIdOKconditioned.size()>0){
          creditCheck='OK_conditioned';

          oppList=retrieveOpp(oppListIdOKconditioned);
        
          sendEmail(oppList, mapNew, 'R163');

          updateOpp(oppList,creditCheck);
      }


  }
  
  private static List<Opportunity>  retrieveOpp(List<Id> oppListId){
    List<Opportunity> oppList=[select Id,XC_CreditCheck_GB__c, Owner.Name, Owner.Email from opportunity
                                                            where Id IN:oppListId];
       system.debug('List Opp return'+' '+ oppList);                                                     
       return oppList;
                              
  } 

  private static void updateOpp (List<Opportunity> oppList,string creditCheck){
    for(Opportunity opp:oppList){
      opp.XC_CreditCheck_GB__c=creditCheck;
    }
     update oppList;
  }

  private static void sendEmail(List<Opportunity> listOp, Map<Id,Case> mapNew, String resolutionValue){
           
      List<string> toAddress = new List<string>();
      List<String> toName = new List<String>();
      List<String> caseName = new List<String>();
      Map<String,String> row = new Map<String,String>();
      Schema.DescribeFieldResult fr = Case.XC_Resolution__c.getDescribe();
      List<Schema.PicklistEntry> entryList = fr.getPicklistValues();
      for(Schema.PickListEntry ple : entryList){
          row.put(ple.getValue(),ple.getLabel());
      }

      List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
      caseName.add(mapNew.values()[0].casenumber);
      for(Opportunity op : listOp){
          for(Case ca : mapNew.values()) {
              if(op.id == ca.XC_Opportunity__c) {
                  toAddress.add(op.Owner.Email);
                  toName.add(op.Owner.name);             
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  mail.setToAddresses(toAddress);
                  mail.setSubject('Credit Check Closure');
                  mail.setHTMLBody(String.format(Label.XC_CL_CreditCheck_HTML, New List<String>{
                          op.Owner.Email, ca.casenumber, row.get(resolutionValue)
                  }));
                  mail.setSaveAsActivity(false);
                  mail.setUseSignature(false);
                  allmsg.add(mail);
              }
          }
      }

      try {
          Messaging.sendEmail(allmsg,false);
          return;
      }catch (Exception e) {
          System.debug(e.getMessage());
      }

  }
}