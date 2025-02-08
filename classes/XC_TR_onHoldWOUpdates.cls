/**
* @author Nicola Arrigo
* @date Creation dd/mm/yyyy
* @date Modification 17/05/2022 FA/GDB - PERFORMANCE IMPROVEMENT
* @description  
*/ 
public with sharing class XC_TR_onHoldWOUpdates {

    public static void oonHoldWOFillSuspencion(List<WorkOrder> woList, Map <id,WorkOrder> mapOld){
        List<id> woIdList=new List<id>();
        List<WorkOrder> woListTocheck=new List<WorkOrder>();
        for(WorkOrder wo:woList){
            if(
                wo.Status=='On Hold' &&
                (wo.XC_Segment__c=='B2B' || wo.XC_Segment__c=='B2G') &&
                wo.Status!=mapOld.get(wo.id).Status
            ){
                woListTocheck.add(wo);
                woIdList.add(wo.id);
            }
        }
        if(woListTocheck.isEmpty()){
            return;
        }
        checkWO(woListTocheck,woIdList);            
    }
    
    /**
    * @author Nicola Arrigo
    */ 
    public static void checkWO(List<WorkOrder> woListTocheck,List<id> woIdList){
        
        List<ServiceAppointment> saList=[select id,XC_Notesforsuspensionandresolution__c, XC_ReasonforSuspension__c,ParentRecordId,Status from ServiceAppointment
                                         where ParentRecordId IN:woIdList and 
                                         status!='On Hold' and 
                                         status!='Completed' and 
                                         status!='Canceled'
                                         order by createddate desc];
        if(saList.isEmpty()){
            system.debug('no saList');  
            return;
        }
        for(WorkOrder wo:woListTocheck){
            for(ServiceAppointment sa:saList){
                if(sa.ParentRecordId==wo.id){
                    if(sa.XC_Notesforsuspensionandresolution__c!=null ||
                       sa.XC_ReasonforSuspension__c!=null){
                           wo.XC_ReasonforSuspension__c=sa.XC_ReasonforSuspension__c;
                           wo.XC_Notesforsuspensionandresolution__c=sa.XC_Notesforsuspensionandresolution__c;
                           system.debug('NA ***** NO ERRORS found');
                       }else{
                           wo.adderror(Label.XC_CL_FillRequiredFields);
                       }
                    break;
                }    
            }
        }
    }
    
    /**
    * @author Nicola Arrigo
    */ 
    public static void updateSA(List<WorkOrder> woList, Map <id,WorkOrder> mapOld){
        
        List<id> woIdList=new List<id>();
        system.debug('enter UpdateSA');
        List<WorkOrder> woListTocheck=new List<WorkOrder>();
        for(WorkOrder wo:woList){
            if(
                wo.Status=='On Hold' &&
                (wo.XC_Segment__c=='B2B' || wo.XC_Segment__c=='B2G') &&
                wo.Status!=mapOld.get(wo.id).Status
            ){
                woListTocheck.add(wo);
                woIdList.add(wo.id);
            }
        }
        if(woListTocheck.isEmpty()){
            return;
        }
        List<ServiceAppointment> saList=[select id,XC_Notesforsuspensionandresolution__c, XC_ReasonforSuspension__c,ParentRecordId,Status from ServiceAppointment
                                         where ParentRecordId IN:woIdList and 
                                         status!='On Hold' and 
                                         status!='Completed' and 
                                         status!='Canceled'
                                         order by createddate desc];
        if(saList.isEmpty()){
            system.debug('No SA found');
            return;
            
        }
        system.debug('SA LIST '+saList);
        for(ServiceAppointment sa:saList){
            sa.Status='On Hold';                 
        }
        update saList;
    }
    
    /**
    * @author Nicola Arrigo
    */ 
    public static void ReplanningWO(List<WorkOrder> woList, Map <id,WorkOrder> mapOld){
        
        List<id> woIdList=new List<id>();
        List<WorkOrder> woListTocheck=new List<WorkOrder>();
        for(WorkOrder wo:woList){
            if(
                (wo.Status=='Assigned' || wo.Status=='In Progress')  &&
                (wo.XC_Segment__c=='B2B' || wo.XC_Segment__c=='B2G') &&
                wo.Status!=mapOld.get(wo.id).Status &&
                mapOld.get(wo.id).Status=='On Hold'
            ){
                woListTocheck.add(wo);
                woIdList.add(wo.id);
            }
        }
        if(woListTocheck.isEmpty()){
            return;
        }
        checkReplanningWO(woListTocheck,woIdList);
    }
    
    /**
    * @author Nicola Arrigo
    */ 
    public static void checkReplanningWO(List<WorkOrder> woListTocheck,List<id> woIdList){
        
        List<ServiceAppointment> saList=[select id,XC_Notesforsuspensionandresolution__c, XC_ReasonforSuspension__c,ParentRecordId,Status,XC_NotesforResolution__c 
                                         from ServiceAppointment
                                         where ParentRecordId IN:woIdList and 
                                         status='On Hold' 
                                         order by createddate desc];
        if(saList.isEmpty()){
            return;
        }
        //Update on Work Order field
        for(WorkOrder wo:woListTocheck){
            for(ServiceAppointment sa:saList){
                if(sa.ParentRecordId==wo.id){
                    if(sa.XC_NotesforResolution__c!=null){
                        wo.XC_NotesforResolution__c=sa.XC_NotesforResolution__c;
                    }else{
                        wo.adderror(Label.XC_CL_FillRequiredFieldsReplanning);
                    }
                }
            }
        }   
    }
    
    /**
    * @author Nicola Arrigo
    */ 
    public static void updateSAReplanning(List<WorkOrder> woList, Map <id,WorkOrder> mapOld){
        List<id> woIdList=new List<id>();
        system.debug('enter UpdateSA');
        List<WorkOrder> woListTocheck=new List<WorkOrder>();
        for(WorkOrder wo:woList){
            if(
                (wo.Status=='Assigned' || wo.Status=='In Progress')  &&
                (wo.XC_Segment__c=='B2B' || wo.XC_Segment__c=='B2G') &&
                wo.Status!=mapOld.get(wo.id).Status &&
                mapOld.get(wo.id).Status=='On Hold'
            ){
                woListTocheck.add(wo);
                woIdList.add(wo.id);
            }
        }
        if(woListTocheck.isEmpty()){
            return;
        }
        List<ServiceAppointment> saList=[select id,XC_Notesforsuspensionandresolution__c, XC_ReasonforSuspension__c,ParentRecordId,Status from ServiceAppointment
                                         where ParentRecordId IN:woIdList and 
                                         status='On Hold'];
        if(saList.isEmpty()){
            return;
        }
        system.debug('SA LIST '+saList);
        for(WorkOrder wo:woList){
            for(ServiceAppointment sa:saList){
                if(sa.ParentRecordId==wo.id){
                    if(wo.Status=='Assigned'){
                        sa.Status='Scheduled';
                    }else if(wo.Status=='In Progress'){
                        sa.Status='In Progress';   
                    }
                }
            }
        }
        update saList;      
    }
}