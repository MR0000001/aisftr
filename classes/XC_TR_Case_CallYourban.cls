/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @createdDate 27/10/2020
* @description classes. XC_TR_Case_CallYourban
*/
public with sharing class XC_TR_Case_CallYourban {
    /**
* @author Nicola Arrigo - narrigo@deloitte.it 
*@description classes.onInsertCase
*/
   public static void callOnInsert(List<case> listNew){
       system.debug('enter method callInsertYourban');
       List<case> caseTobeSend=new List<case>();
       List<id> listTecAssetId=new List<id>();
       List<id> caseId=new List<id>();
       for(case c:listNew){
           if( sendToYourban(c)==true && 
              c.Origin=='CAN001' &&
              c.XC_TechnicalAsset__c!=null){
               listTecAssetId.add(c.XC_TechnicalAsset__c); 
               caseId.add(c.id);
       }
   }
       if(caseId.isEmpty()){
           return;
       }
  /*   Map<id,Asset> techAssetMap=new Map<id,Asset>([select id,XC_Address__r.Name
                                      from Asset
                                      where id IN:listTecAssetId]);*/
  // NR2059 - Eleni Tsiolaki - 30/11/2021 - Added the XC_eCityProductArea__c field on the query
  List<case> cList=[select id,Contact.Name,XC_TechnicalAsset__r.XC_Address__r.Name,XC_TechnicalAsset__c,RecordTypeId,Description,Reason,SubCause__c,
                   XC_Subtype__c,AccountId,XC_FaultType__c,XC_DefectType__c,XC_DefectDescription__c,XC_BusinessLine__c, XC_eCityProductArea__c,
                   XC_Segment__c,Status,Origin,ClosedDate,CreatedDate,CaseNumber
                   from case 
                   where id IN:caseId];
       if(cList.size()==0){
           return;
       }                 
       for(case c:cList){
               caseTobeSend.add(c);
              XC_UTIL_Case.CaseRESTWrapper caseWr=new XC_UTIL_Case.CaseRESTWrapper();
              caseWr.CaseID=c.id;
             // string s = string.valueOfGmt(c.ClosedDate);
              string createDate=string.valueOfGmt(c.CreatedDate);
              caseWr.CreatedDate=createDate;
           //caseWr.ClosedDate=s;
              caseWr.CaseNumber=c.CaseNumber;
              caseWr.RecordTypeId=c.RecordTypeId;
              caseWr.Description=c.Description;
              caseWr.Origin=c.Origin;
              caseWr.CaseReason=c.Reason;
              caseWr.CaseSubCause=c.SubCause__c;
              casewr.CaseSubType=c.XC_Subtype__c;
              caseWr.AccountID=c.AccountId;
          //    caseWr.ContactID=c.ContactId;
              caseWr.FaultType=c.XC_FaultType__c;
              caseWr.DefectType=c.XC_DefectType__c;
              caseWr.DefectDescription=c.XC_DefectDescription__c;
             /* if(c.XC_TechnicalAsset__c!=null){
                  casewr.TechnicalAssetId=c.XC_TechnicalAsset__c;
                  if(techAssetMap.get(c.XC_TechnicalAsset__c).XC_Address__r.Name!=null){
                     casewr.AddressTA=techAssetMap.get(c.XC_TechnicalAsset__c).XC_Address__r.Name;
                  }   
              }*/
              if(c.XC_TechnicalAsset__c!=null){
               casewr.TechnicalAssetId=c.XC_TechnicalAsset__c;
               casewr.AddressTA=c.XC_TechnicalAsset__r.XC_Address__r.Name;
              }
              casewr.BusinessLine=c.XC_BusinessLine__c;
              casewr.Segment=c.XC_Segment__c;
              casewr.Status=c.Status; 
              casewr.ReportedByName=c.Contact.Name;              
              // NR2059 - Eleni Tsiolaki - 30/11/2021 - add the XC_eCityProductArea__c field on the wrapper
              casewr.eCityProductArea = c.XC_eCityProductArea__c;
              system.debug('Wrapper '+casewr);
              callToCreate(JSON.serialize(casewr));
             // XC_REST_Case_Outbound.callToCreateCase(caseWr);
                        
         }
        system.debug('List case to be send '+caseTobeSend);
         //cal rest
  }

   public static void callOnUpdate(List<case> listNew, Map<id,Case> olMap){
      system.debug('enter method callOnUpdateYourban');
   List<id> listTecAssetId=new List<id>();
   List<id> caseId=new List<id>();
   List<Case> cList=new List<case>();
   list<id> caseIdNew=new List<id>();
       for(case c:listNew){
           system.debug('c Status '+c.Status);
           system.debug('c TA '+c.XC_TechnicalAsset__c);
           if( sendToYourban(c)==true && 
              c.XC_TechnicalAsset__c!=null){
               listTecAssetId.add(c.XC_TechnicalAsset__c);   
               caseId.add(c.id);
               cList.add(c);
               system.debug('case to be check for Yourban '+c);
       }
   }
   system.debug('caseId '+caseId);
   if(caseId.isEmpty()){
       return;
   }
   for(case c:cList){
    system.debug('status case '+c.Status);
    system.debug('old status '+olmap.get(c.id).Status);
    if((c.Status!=olmap.get(c.id).Status &&
            (c.Status=='ESTA003' ||
            c.Status=='ESTA004' ||
            c.Status=='ESTA002'   
            )
        )||c.Status=='ESTA007'||
        (c.XC_TechnicalAsset__c!=olmap.get(c.id).XC_TechnicalAsset__c)
    ){
       // caseIdNew.add(c.id);
       //call future method
       list <id> caseIdList=new List<id>();
       caseIdList.add(c.id);
        SYSTEM.DEBUG('CALL FUTURE '+c.id);
       futureOnUpdate(caseIdList); 
    }
  }
   /*  Map<id,Asset> techAssetMap=new Map<id,Asset>([select id,XC_Address__r.Name
                                      from Asset
                                      where id IN:listTecAssetId]);  */
   //call future method
   //futureOnUpdate(caseIdNew);
} 
   @future (callout=true)
   public static void futureOnUpdate(List<ID> caseIdNew){
    system.debug('enter method futureOnUpdate');
    List<case> caseTobeSend=new List<case>(); 
                List<case> cList=[select id,Contact.Name,XC_TechnicalAsset__r.XC_Address__r.Name,XC_TechnicalAsset__c,RecordTypeId,Description,Reason,SubCause__c,
                XC_Subtype__c,AccountId,XC_FaultType__c,XC_DefectType__c,XC_DefectDescription__c,XC_BusinessLine__c,
                XC_Segment__c,Status,Origin,ClosedDate,CreatedDate,CaseNumber,XC_DateCaseSuspended__c, XC_eCityProductArea__c,
                (select id,TargetDate,IsViolated from caseMilestones limit 1),
                (select id,XC_Notesforsuspensionandresolution__c,XC_ReasonforSuspension__c,XC_NotesforResolution__c from WorkOrders 
                where Status!='Canceled' and status!='Completed')
                from case
                where id IN:caseIdNew]; 
            if(cList.size()==0){
            return;
            }                                                                
            for(case c:cList){
            system.debug('status case '+c.Status);
            system.debug('to be send to Yourban '+c);   
            caseTobeSend.add(c); 
            // caseTobeSend.add(c);
            XC_UTIL_Case.CaseRESTWrapper caseWr=new XC_UTIL_Case.CaseRESTWrapper();
            string s = string.valueOfGmt(c.ClosedDate);
            string createDate=string.valueOfGmt(c.CreatedDate);
            caseWr.CreatedDate=createDate;
            caseWr.ClosedDate=s;               
            caseWr.CaseID=c.id;
            caseWr.CaseNumber=c.CaseNumber;
            caseWr.RecordTypeId=c.RecordTypeId;
            //START - federico.manni@accenture.com - fix INC000086197927
            caseWr.Description=c.Description;
            //END - federico.manni@accenture.com - fix INC000086197927
            caseWr.CaseReason=c.Reason;
            casewr.CaseSubCause=c.SubCause__c; 
            casewr.CaseSubType=c.XC_Subtype__c;
            casewr.AccountID=c.AccountId;
            // casewr.ContactID=c.ContactId;
            casewr.FaultType=c.XC_FaultType__c;
            casewr.DefectType=c.XC_DefectType__c;
            casewr.DefectDescription=c.XC_DefectDescription__c;
            /*if(c.XC_TechnicalAsset__c!=null){
            casewr.TechnicalAssetId=c.XC_TechnicalAsset__c;
            if(techAssetMap.get(c.XC_TechnicalAsset__c).XC_Address__r.Name!=null){
                casewr.AddressTA=techAssetMap.get(c.XC_TechnicalAsset__c).XC_Address__r.Name;
            }   
            }*/
            if(c.XC_TechnicalAsset__c!=null){
               casewr.TechnicalAssetId=c.XC_TechnicalAsset__c;
               casewr.AddressTA=c.XC_TechnicalAsset__r.XC_Address__r.Name;
              }
            // NR2059 - Eleni Tsiolaki - 30/11/2021 - add the XC_eCityProductArea__c field on the wrapper
            casewr.eCityProductArea = c.XC_eCityProductArea__c;
            casewr.BusinessLine=c.XC_BusinessLine__c;
            casewr.Segment=c.XC_Segment__c;
            casewr.Status=c.Status; 
            casewr.ReportedByName=c.Contact.Name;
            if(c.XC_DateCaseSuspended__c!=null){
          /*  dateTime suspensionDate;
            suspensionDate=c.XC_DateCaseSuspended__c;
            date suspendedDate=date.newinstance(suspensionDate.year(),suspensionDate.month(), suspensionDate.day()); */
             string SuspensionDate=string.valueOfGmt(c.XC_DateCaseSuspended__c);
           casewr.SuspensionDate=SuspensionDate;   
            }
            if(!c.caseMilestones.isEmpty()){
            if(c.caseMilestones[0].TargetDate!=null){
               // dateTime targetDate;
               // targetDate=c.caseMilestones[0].TargetDate;
                //casewr.TargetDate=c.caseMilestones[0].TargetDate; 
                //date startMilestone=date.newinstance(targetDate.year(),targetDate.month(), targetDate.day());   
                string TargetDate=string.valueOfGmt(c.caseMilestones[0].TargetDate);
                casewr.TargetDate= TargetDate;
              /* DateTime dt=c.caseMilestones[0].TargetDate;
               String formatedDt = dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); 
                casewr.TargetDate=formatedDt; */
            }
             
            if(c.caseMilestones[0].IsViolated!=null){
                casewr.IsViolated=c.caseMilestones[0].IsViolated;
            }
            }
            if(!c.WorkOrders.isEmpty()){
           // casewr.NotesForSuspensionAndResolution=c.WorkOrders[0].XC_Notesforsuspensionandresolution__c;
            casewr.ReasonForSuspension=c.WorkOrders[0].XC_ReasonforSuspension__c;
           // casewr.NotesForResolution=c.WorkOrders[0].XC_NotesforResolution__c;
            }

            system.debug('Wrapper '+casewr);
            //callToUpdate(Json.serialize(casewr));
            XC_REST_Case_Outbound.callToUpdateCase(caseWr);
            }
            system.debug('List case to be send '+caseTobeSend);
            //call rest
}   
    /**
* @author Nicola Arrigo - narrigo@deloitte.it 
*@description sendToUrban
*/
  public static boolean sendToYourban(case c){
   boolean trovato=false;   
   if(c.Reason=='XCMOT002' &&
         c.SubCause__c=='ATCL003'&&
         (c.XC_Subtype__c=='XC199')&&
         c.XC_BusinessLine__c=='eCity'
         ){
         trovato=true; 
      }
      system.debug('string Yourban '+c.Reason+'_'+c.XC_Subtype__c+'_'+c.XC_BusinessLine__c);
      system.debug('Case For Yourban '+trovato);
      return trovato;
  }
  /**
* @author Nicola Arrigo - narrigo@deloitte.it 
*@description callToCreate
*/

@future(callout=true)
public static void callToCreate( string caseWrString){
   XC_UTIL_Case.CaseRESTWrapper caseWr=(XC_UTIL_Case.CaseRESTWrapper) JSON.deserialize(caseWrString, XC_UTIL_Case.CaseRESTWrapper.class);
   XC_REST_Case_Outbound.callToCreateCase(caseWr);
}

/**
* @author Nicola Arrigo - narrigo@deloitte.it 
*@description callToCreate
*/
/*

    @future(callout=true)
    public static void callToUpdate( string caseWrString){
        system.debug('enter method callToUpdate Yourban');
    XC_UTIL_Case.CaseRESTWrapper caseWr=(XC_UTIL_Case.CaseRESTWrapper) JSON.deserialize(caseWrString, XC_UTIL_Case.CaseRESTWrapper.class);
    XC_REST_Case_Outbound.callToUpdateCase(caseWr);

}*/


}