/**
 * Created by snekkanti002 on 02/11/2022.
 */

@IsTest
public without sharing class TestMacrostructureAssociationDAO {
    @IsTest
    public static void getMAbyUserIdAndStructureId() {
        Test.startTest();
        MacrostructureAssociationDAO.getMAbyUserIdAndStructureId('testuserid');
        Test.stopTest();
    }
}