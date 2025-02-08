/**
* @author Tommaso Precania - tommaso.precania@accenture.com
* @date Creation 01/12/2021
* @date Modification 10/12/2021
* @description XC_SC064_QRGBatchJob – Scheduler Class to schedule execution of the XC_BA002_QRGBatchJob batch
*/
public with sharing class XC_SC064_QRGBatchJob implements Schedulable{
    public Integer numberOfDaysAgo;
    public Integer scopeSize;
    public XC_SC064_QRGBatchJob(Integer daysAgo, Integer scSize){
        this.numberOfDaysAgo = daysAgo;
        this.scopeSize = (scSize != null && scSize > 0 && scSize <= 100) ? scSize : 100;
    }
    public void execute(SchedulableContext sc) {
        ID batchId = Database.executeBatch(new XC_BA002_QRGBatchJob(this.numberOfDaysAgo), this.scopeSize);
    }
}