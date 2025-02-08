/**
* @author FSL Team: Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com 
* @date Creation 16/03/2021
* @description XC_SC042_UpdateFlagAutoschedule – Schedulable class to update FSL Autoschedule standard flag
*/

public without sharing class XC_SC042_UpdateFlagAutoschedule implements Schedulable { 
    
    public void execute(SchedulableContext sc) { 
        updateFlag(); 
    } 
 
    public static void updateFlag() {
        Integer totalSize = 20; 

        List<XC_CM_Scheduling_Default_Value__mdt> listCM = [
            SELECT XC_SizeAutoscheduleStandard__c 
            FROM XC_CM_Scheduling_Default_Value__mdt 
            WHERE XC_SizeAutoscheduleStandard__c != null 
            LIMIT 1
        ];
        if(!listCM.isEmpty()){
            totalSize = Integer.valueOf(listCM[0].XC_SizeAutoscheduleStandard__c);
        }
        
        String queryB2B = 'SELECT Id FROM ServiceAppointment';
        queryB2B += ' WHERE XC_ProcessedWithStandardAutoschedule__c = false AND Status =\'None\'';
        queryB2B += ' AND (XC_Segment__c = \'B2B\' OR XC_Segment__c = \'B2G\')';
        queryB2B += ' LIMIT '+ totalSize;
        
        List<ServiceAppointment> listSAB2B = Database.query(queryB2B);
        Integer sizeB2B = listSAB2B.size();
        Integer sizeB2C = totalSize - sizeB2B;
        
        List<ServiceAppointment> listSAToUpdate = new List<ServiceAppointment>();
        
        for(ServiceAppointment sa : listSAB2B){ 
            sa.FSL__Auto_Schedule__c = true; 
            sa.XC_ProcessedWithStandardAutoschedule__c = true;
            listSAToUpdate.add(sa);
        }
        if(sizeB2C > 0){
            String queryB2C = 'SELECT Id FROM ServiceAppointment';
            queryB2C += ' WHERE XC_ProcessedWithStandardAutoschedule__c = false AND Status =\'None\'';
            queryB2C += ' AND XC_Segment__c = \'B2C\' AND XC_WorkTypeCategory__c = \'Planned Maintenance\'';
            queryB2C += ' LIMIT ' + sizeB2C;
            
            List<ServiceAppointment> listSAB2C = Database.query(queryB2C);
            
            
            for(ServiceAppointment sa : listSAB2C){ 
                sa.FSL__Auto_Schedule__c = true; 
                sa.XC_ProcessedWithStandardAutoschedule__c = true;
                listSAToUpdate.add(sa);
            }
        }
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        if(!Test.isRunningTest()){
            XC_UTIL_Sobject.updateListRecords(listSAToUpdate, false);
        }
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false); 
    }   
}