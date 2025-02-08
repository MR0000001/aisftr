global class XC_SB_EditBusinessDataBatch implements Schedulable { 
    global void execute(SchedulableContext sc) {
    XC_BA_EditBusinessDataBatch batchJob = new XC_BA_EditBusinessDataBatch();
    Database.executeBatch(batchJob); 
} 
}