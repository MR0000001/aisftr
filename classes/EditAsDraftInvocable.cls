/**
 * Created by RGAROFALO00 on 30/06/2020.
 */

public with sharing class EditAsDraftInvocable {

    @InvocableMethod
    public static void editOnlineArticle(List<String> articleIdString){
        for(String stringThis : articleIdString ){
            String id = KbManagement.PublishingService.editOnlineArticle (stringThis, false);
        }
    }
}