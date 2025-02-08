global class XC_FutureProductRequiredUpdate{

  @future
  public static void updateProductRequired(String woliId) {
      System.debug('Woli: ' + woliId);
      List<XC_ProductConsumed__c> relatedConsumeds = [SELECT Id, XC_ProductRequired__c, XC_OriginalConsumedQuantity__c ,XC_QuantityConsumed__c, XC_ProductRequired__r.XC_Quantity__c, XC_ProductRequired__r.XC_QuantityConsumed__c
                                                        FROM XC_ProductConsumed__c
                                                        WHERE XC_WorkOrderLineItem__c =: woliId ];
      List<ProductRequired> prToUpdate = new List<ProductRequired>();
      List<XC_ProductConsumed__c> pcToUpdate = new List<XC_ProductConsumed__c>();
      if (!relatedConsumeds.isEmpty()) {
          for (XC_ProductConsumed__c pc: relatedConsumeds){
              if (pc.XC_ProductRequired__c != null) {
                  ProductRequired tempPR = new ProductRequired();
                  tempPR.Id = pc.XC_ProductRequired__c;
                  if (pc.XC_QuantityConsumed__c != null ) {
                      tempPR.XC_QuantityConsumed__c = pc.XC_QuantityConsumed__c;
                  }
                  if (pc.XC_ProductRequired__r.XC_QuantityConsumed__c != null) {
                      tempPR.XC_QuantityConsumed__c = tempPR.XC_QuantityConsumed__c + pc.XC_ProductRequired__r.XC_QuantityConsumed__c;
                  }
                  prToUpdate.add(tempPR);
              }

              if (pc.XC_OriginalConsumedQuantity__c == null || pc.XC_OriginalConsumedQuantity__c == 0) {
                  pc.XC_OriginalConsumedQuantity__c = pc.XC_QuantityConsumed__c;
              }
              /*if (pc.XC_ProductRequired__r.XC_Quantity__c!= null ) {
                  pc.XC_PlannedRemainingMaterialRequest__c = pc.XC_ProductRequired__r.XC_Quantity__c - pc.XC_QuantityConsumed__c;
              }*/
              pcToUpdate.add(pc);

          }
      }
      System.debug('updateProductRequired() - prToUpdate: ' + prToUpdate);
      if (!prToUpdate.isEmpty()) {
          XC_UTIL_Sobject.updateListRecords(prToUpdate);
      }
      if (!pcToUpdate.isEmpty()) {
          XC_UTIL_Sobject.updateListRecords(pcToUpdate);
      }
  }

}