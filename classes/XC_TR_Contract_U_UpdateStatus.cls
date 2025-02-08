/**
* @author Valentina De Blasio - valentina.de.blasio@accenture.com
* @date Creation 22/04/2022
* @description XC_TR_Contract_U_UpdateStatus update status wo and status serviceappoiment 
*/

public class XC_TR_Contract_U_UpdateStatus {
    public static void checkStatus(Map<Id, Contract> mapOld, Map<Id, Contract> mapNew){
            List<String> fieldList = new List<String>{'XC_Signed__c'};
            Set<Id> coId=new Set<Id>();
            List<ServiceAppointment> updateSAInprogress=new List<ServiceAppointment>();
            Set<Id> idappoiment=new Set<Id>();
            List<Contract> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
            if(!listChanged.isEmpty()){   	
                for(Contract co:listChanged){
                    if(co.XC_Signed__c==true){
                        coId.add(co.id);
                    }
                }
            }  
        list<Contract> listcont=[SELECT Id,Opportunity__r.XC_WorkOrder__c,Opportunity__r.XC_WorkOrder__r.CaseId, Opportunity__r.XC_WorkOrder__r.XC_LegalEntity__c, Opportunity__r.XC_WorkOrder__r.XC_WorkTypeCategory__c, Opportunity__r.XC_WorkOrder__r.XC_Segment__c, Opportunity__r.XC_WorkOrder__r.Case.XC_BusinessLine__c,Opportunity__r.XC_ServiceAppointment__c  
                                 from Contract where Id in:coId and (Opportunity__r.XC_WorkOrder__r.XC_LegalEntity__c = 'EnelSole' or Opportunity__r.XC_WorkOrder__r.XC_LegalEntity__c='EnelXItalia') and Opportunity__r.XC_WorkOrder__r.XC_WorkTypeCategory__c ='Malfunctioning'  and (Opportunity__r.XC_WorkOrder__r.XC_Segment__c='B2B' or Opportunity__r.XC_WorkOrder__r.XC_Segment__c ='B2G') and Opportunity__r.XC_WorkOrder__r.Case.XC_BusinessLine__c='eCity'];
        if(!listcont.isEmpty()){
            for(Contract cont: listcont){
                idappoiment.add(cont.Opportunity__r.XC_ServiceAppointment__c);
            }       
            List<ServiceAppointment> listsa=[Select id,status,XC_NotesforResolution__c from ServiceAppointment where id in:idappoiment];
            if(!listsa.isEmpty()){
                for(ServiceAppointment sapp :listsa){
                    sapp.Status = 'In Progress';
                    updateSAInprogress.add(sapp);
                    }
                update updateSAInprogress;
                ServiceAppCompleted(coId);
            }
        }    
     }
       
        public static void ServiceAppCompleted(Set<Id> idContract){
         Set<Id> coId=new Set<Id>();
         Set<Id>  idappoiment=new Set<Id>();
         List<ServiceAppointment> serviceCompleted=new List<ServiceAppointment>();
        list<Contract> listcont=[SELECT Id,Opportunity__r.XC_WorkOrder__c,Opportunity__r.XC_WorkOrder__r.CaseId, Opportunity__r.XC_WorkOrder__r.XC_LegalEntity__c, Opportunity__r.XC_WorkOrder__r.XC_WorkTypeCategory__c, Opportunity__r.XC_WorkOrder__r.XC_Segment__c, Opportunity__r.XC_WorkOrder__r.Case.XC_BusinessLine__c,Opportunity__r.XC_ServiceAppointment__c  
                                 from Contract where Id in:idContract and Opportunity__r.XC_WorkOrder__r.status='In Progress'];
        if(!listcont.isEmpty()){
            for(Contract cont: listcont){
                idappoiment.add(cont.Opportunity__r.XC_ServiceAppointment__c);
            }    
        }
        List<ServiceAppointment> listsa=[Select id,status,XC_NotesforResolution__c from ServiceAppointment where id in:idappoiment];
        if(!listsa.isEmpty()){
           for(ServiceAppointment sa:listsa){
                sa.Status='Completed';
                if(sa.XC_NotesforResolution__c !=null){
                  sa.XC_NotesforResolution__c=sa.XC_NotesforResolution__c+'-'+'Preventivo Accettato';
                  }else{
                    sa.XC_NotesforResolution__c = 'Preventivo Accettato';
                  }
                serviceCompleted.add(sa);
           }
            update serviceCompleted;
            }
        }
        }