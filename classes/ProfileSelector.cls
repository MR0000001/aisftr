/**
 * Created by SNEKKANTI00 on 08/02/2021.
 */

public with sharing class ProfileSelector {
    public static String getProfileNameById(String profileId) {
        List<Profile> currentUserProfiles = [SELECT Name FROM Profile WHERE id =: profileId LIMIT 1];

        if(currentUserProfiles != null && !currentUserProfiles.isEmpty()) return currentUserProfiles[0].Name;

        return null;
    }
}