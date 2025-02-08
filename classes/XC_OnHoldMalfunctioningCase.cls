/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation 12/03/2021
* @date Modification MAY 2022 - PERFORMANCE IMPROVEMENT - GDB/FA
* @description XC_OnHoldMalfunctioningCase 
*/
public with sharing class XC_OnHoldMalfunctioningCase {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_OnHoldMalfunctioningCase');
    
    public static void onHoldMalfunctioning(List<WorkOrder> woList, Map <id,WorkOrder> mapOld){
    
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ newCase =');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_OnHoldMalfunctioningCase ');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ method1=');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ onholdmalfunctiong'); 
        Map<id,DateTime> mapDueDateWO=new Map<id,DateTime>();
        List<id> caseOnHoldList=new List<id>();
        // Map<id,id> mapWoCaseId=new Map<id,id>();
       
        for(WorkOrder wo:woList){
            if(wo.XC_WorkTypeCategory__c=='Malfunctioning' &&
               wo.CaseId!=null &&
               wo.Status=='On Hold' &&
               (wo.XC_Segment__c=='B2B' || wo.XC_Segment__c=='B2G') &&
               wo.Status!=mapOld.get(wo.id).Status
              ){
                  caseOnHoldList.add(wo.CaseId);
                  mapDueDateWO.put(wo.CaseId,wo.XC_DueDate__c);
              }
        }
        if(caseOnHoldList.isEmpty()){
            return;
        }
        
        //PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA - START        
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(new onHoldMalfunctioningAsync(mapDueDateWO, caseOnHoldList));
        }else{
            onHoldMalfunctioningLogic(mapDueDateWO, caseOnHoldList);
        }    
        //PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA - END
    }   
        
    /**
    * @author Nicola Arrigo - narrigo@deloitte.it
    * @date Creation 12/03/2021
    * @description XC_OnHoldMalfunctioningCase 
    */        
	public static void onHoldMalfunctioningLogic(Map<id,DateTime> mapDueDateWO, List<id> caseOnHoldList){     
        
        List<Case> caseParentList=[select id,Status,IsStopped,XC_DateCaseSuspended__c,XC_SLAImprese__c,
                                   (select id,Status,IsStopped,XC_DateCaseSuspended__c,XC_SLAImprese__c from cases 
                                    where (Status!='ESTA002'  and
                                           Status!='ESTA007' and
                                           Status!='ESTA008'   ))
                                   from case 
                                   where (id IN:caseOnHoldList 
                                          and (Status!='ESTA002'  and
                                               Status!='ESTA007' and 
                                               Status!='ESTA008'    ) 
                                         )];
        
        List<Case> caseToBeUpdated=new List<case>();
        for(case cParent:caseParentList){
            Long dtLongNow = Datetime.now().getTime();
            double nowTime=double.valueOf(dtLongNow);
            system.debug('double datetime now '+nowTime);
            Long dtLongDueDateWO=mapDueDateWO.get(cParent.Id).getTime();
            double difference;
            system.debug('difference hours case suspendendc '+difference);
            difference=(dtLongNow-dtLongDueDateWO);
            double diff=difference/(1000*60*60);
            // Long difference=(Datetime.now()-mapDueDateWO.get(cParent.Id))*24;
            system.debug('difference NowDueDate '+difference); 
            system.debug('diff hours '+diff);
            
            if(cParent.cases.size()>0){
                for(case cChild:cParent.cases){
                    cChild.Status='ESTA002';
                    cChild.XC_DateCaseSuspended__c=Datetime.now();
                    cChild.IsStopped=true;
                    cChild.XC_SLAImprese__c=Decimal.Valueof(diff);
                    caseToBeUpdated.add(cChild);
                }
            }
            
            cParent.Status='ESTA002';
            cParent.XC_DateCaseSuspended__c=Datetime.now();
            cParent.IsStopped=true;
            cParent.XC_SLAImprese__c=Decimal.ValueOf(diff);
            caseToBeUpdated.add(cParent);
        }
        update caseTobeUpdated; 
    }
    
    /**
    * @author Nicola Arrigo - narrigo@deloitte.it
    * @description inProgressdMalfunctioning 
    */
    public static void inProgressdMalfunctioning(List<WorkOrder> woList, Map <id,WorkOrder> mapOld){
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ newCase =');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_OnHoldMalfunctioningCase ');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ method2=');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ inProgressdMalfunctioning');
        List<id> listIdCase=new List<id>();
        List<WorkOrder>woListToBeUpdated=new List<WorkOrder>();
        system.debug('Datetime : '+ DateTime.now());
        system.debug('timestamp : '+ DateTime.now().getTime());
        
        for(WorkOrder wo:woList){
            if(wo.XC_WorkTypeCategory__c=='Malfunctioning' &&
               wo.CaseId!=null &&
               mapOld.get(wo.id).Status=='On Hold' &&
               (wo.XC_Segment__c=='B2B' || wo.XC_Segment__c=='B2G') &&
               wo.Status!=mapOld.get(wo.id).Status
              ){
                  listIdCase.add(wo.CaseId);
                  woListToBeUpdated.add(wo);
              }
        }
        if(woListToBeUpdated.isEmpty()){
            return;
        }
        
        List<Case> caseParentList=[select id,Status,IsStopped,XC_DateCaseSuspended__c,
                                   (select id,TimeRemainingInMins,TimeRemainingInDays  from CaseMilestones order by createddate desc)
                                   from case 
                                   where (id IN:listIdCase)];
        
        for(WorkOrder wo:woListToBeUpdated){
            for(Case cParent:caseParentList){
                if(wo.CaseId==cParent.id){
                    if(cParent.CaseMilestones.size()>0){
                        integer daysRemaining=Integer.valueOf(cParent.CaseMilestones[0].TimeRemainingInDays);List<String> filterLogicSplittedbySpace = cParent.CaseMilestones[0].TimeRemainingInMins.split(':');
                        system.debug('first part '+filterLogicSplittedbySpace[0]);
                        system.debug('second part '+filterLogicSplittedbySpace[1]);
                        system.debug('daysRemaining '+daysRemaining);
                        string minString;
                        string secString;
                        
                        if(filterLogicSplittedbySpace[0].startsWith('0')){
                            minString=filterLogicSplittedbySpace[0].substring(1);
                        }else{
                            minString=filterLogicSplittedbySpace[0];
                        }
                        if(filterLogicSplittedbySpace[1].startsWith('0')){
                            secString=filterLogicSplittedbySpace[1].substring(1);      
                        }
                        else{
                            secString=filterLogicSplittedbySpace[1];
                        }
                        
                        integer min=Integer.valueOf(minString);
                        integer sec=Integer.valueOf(secString);
                        system.debug('min returns '+min);
                        system.debug('sec returns '+sec);
                        // wo.XC_DueDate__c=Datetime.now().addDays(daysRemaining);
                        dateTime dAddMin=Datetime.now().addMinutes(min);
                        wo.XC_DueDate__c=dAddMin.addSeconds(sec);
                        
                    }else{
                        wo.XC_DueDate__c=Datetime.now();
                    }
                    
                }
            }
        }                                                
    }
    
    /**
    * @author Nicola Arrigo - narrigo@deloitte.it
    * @description inProgressdMalfunctioning 
    */
    public static void caseUpdate(List<WorkOrder> woList, Map <id,WorkOrder> mapOld){
        
        system.debug('enter method caseUpdate ');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ update=');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_OnHoldMalfunctioningCase ');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ method2=');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ caseUpdate');
        List<id> listIdCase=new List<id>();
        
        for(WorkOrder wo:woList){
            if(wo.XC_WorkTypeCategory__c=='Malfunctioning' &&
               wo.CaseId!=null &&
               mapOld.get(wo.id).Status=='On Hold' &&
               (wo.XC_Segment__c=='B2B' || wo.XC_Segment__c=='B2G') &&
               wo.Status!=mapOld.get(wo.id).Status
              ){
                  listIdCase.add(wo.CaseId);
              }
        }
        if(listIdCase.isEmpty()){
            return;
        }
        
        //PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA - START        
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(new caseUpdateAsync(listIdCase));
        }else{
            caseUpdateLogic(listIdCase);
        }    
        //PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA - END
    }   

    /**
    * @author Nicola Arrigo - narrigo@deloitte.it
    * @description inProgressdMalfunctioning 
    */
    public static void caseUpdateLogic(List<id> listIdCase){
    
        List<Case> caseParentList=[select id,Status,IsStopped,XC_DateCaseSuspended__c,
                                   (select id,Status,IsStopped,XC_DateCaseSuspended__c from cases where Status='ESTA002')
                                   from case 
                                   where (id IN:listIdCase 
                                          and Status='ESTA002')];
        
        system.debug('CaseParentList '+caseParentList);
        List<Case> caseToBeUpdated=new List<case>();
        for(case cParent:caseParentList){
            if(cParent.cases.size()>0){
                for(case cChild:cParent.cases){
                    cChild.Status='ESTA003';
                    cChild.IsStopped=false;
                    caseToBeUpdated.add(cChild);
                }  
            }
            cParent.status='ESTA003';
            cParent.IsStopped=false;
            caseToBeUpdated.add(cParent);   
        }
        system.debug('caseTobeUpdated '+caseTobeUpdated);
        update caseTobeUpdated;                                         
    }
       
    /**
    * @author VDB
    * @date 24-02-22 CR 760 
    */
    public static void updateFieldWo(List<WorkOrder> woList, Map <id,WorkOrder> mapOld){
        
        List<WorkOrder> woListToBeUpdated = new List<WorkOrder>();
        List<WorkOrder> wroList=[SELECT Id,XC_ClosedDateDeclared__c,XC_LegalEntity__c,XC_CheckInDate__c,XC_FaultType__c,EndDate,XC_WorkTypeCategory__c,XC_Segment__c,CaseId,Status,Case.XC_DateCaseSuspended__c,Case.XC_FaultType__c FROM WorkOrder WHERE Id IN:woList];
        
        if(!wroList.isEmpty()){
            Boolean toUpdate;            
            for(WorkOrder wor:wroList){ 
                toUpdate = false;                          
                if(wor.XC_LegalEntity__c=='EnelSole' && wor.XC_WorkTypeCategory__c=='Malfunctioning' && wor.CaseId!=null &&(wor.XC_Segment__c=='B2B' || wor.XC_Segment__c=='B2G')){
                    
                    if(wor.Status=='On Hold'){
                        wor.XC_SuspensionDateTimeDeclared__c=wor.Case.XC_DateCaseSuspended__c;
                        wor.XC_DateCaseSuspended__c=wor.Case.XC_DateCaseSuspended__c;
                        toUpdate = true;                                             
                    }	
                    if(wor.EndDate!=null){
                        wor.XC_ClosedDateDeclared__c=wor.EndDate;
                        toUpdate = true; 
                    }
                    if(wor.Case.XC_FaultType__c!=null){              
                        wor.XC_FaultType__c=wor.Case.XC_FaultType__c; 
                        toUpdate = true;                  
                    }
                    if(mapOld.get(wor.id).Status=='On Hold' && wor.Status=='In Progress'){
                        wor.XC_InProgressDate__c=wor.Case.XC_DateCaseSuspended__c;
                        wor.XC_CheckInDate__c=wor.Case.XC_DateCaseSuspended__c;
                        toUpdate = true; 
                    }
                    
                    if(toUpdate){
                        woListToBeUpdated.add(wor);
                    }
                }       
            }
        }        
		
        //PERFORMANCE IMPROVEMENT - MAY 2022 - GDB
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        if(!Test.isRunningTest() && !woListToBeUpdated.isEmpty()) {
            update woListToBeUpdated;
        }
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        
    }
    
   /**
    * @description INNER QUEABLE CLASS FOR OnHoldMalfunctioning
    * @author PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA 
    * @return Boolean
    */
    public class onHoldMalfunctioningAsync implements Queueable{
        Map<id,DateTime> mapDueDateWO;
        List<id> caseOnHoldList;
        
        public onHoldMalfunctioningAsync(Map<id,DateTime> mapDueDateWO, List<id> caseOnHoldList){
            this.mapDueDateWO = mapDueDateWO;
            this.caseOnHoldList = caseOnHoldList;
        }

        public void execute(QueueableContext context) {
            onHoldMalfunctioningLogic(this.mapDueDateWO, this.caseOnHoldList);
        }
    }    
    
    /**
    * @description INNER QUEABLE CLASS FOR CaseUpdate
    * @author PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA 
    * @return Boolean
    */
    public class caseUpdateAsync implements Queueable{
        List<id> listIdCase;
        
        public caseUpdateAsync(List<id> listIdCase){
            this.listIdCase = listIdCase;
        }

        public void execute(QueueableContext context) {
            caseUpdateLogic(this.listIdCase);
        }
    }   
}