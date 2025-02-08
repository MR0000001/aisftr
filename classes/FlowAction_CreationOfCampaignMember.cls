/**
 * @author            : Davide Desideri
 * @created date      :
 * @description       :
 * @testClasses       : FlowAction_CreationOfCampaignMember_Test
 * @last modified by  : Daniel Perrella
 * @last modified on  : 01-06-2023
 **/
public with sharing class FlowAction_CreationOfCampaignMember {
  @InvocableMethod
  public static void callBatchCreationOfCampaignMember(List<Request> requests) {
    for (Request req : requests) {
      Database.executeBatch(new CreationOfCampaignMember(req.CampaignId), req.BatchSize);
    }
  }

  public class Request {
    @InvocableVariable(required=true)
    public String CampaignId;
    @InvocableVariable(required=true)
    public Integer BatchSize;
  }
}