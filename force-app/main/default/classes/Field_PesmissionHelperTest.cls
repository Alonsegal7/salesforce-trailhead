@isTest
public without sharing class Field_PesmissionHelperTest {
    @isTest
    static void shouldEnableFields() {
        Map<String, String> sobjectsMap = Field_PesmissionHelper.getSObjects();
        system.assertEquals(sobjectsMap.containsKey('Account'), TRUE);
        List<FieldDefinition> fieldList = Field_PesmissionHelper.getfields('Account');
        system.assertNotEquals(fieldList.size(), 0);
        List<String> fieldSubList = new List<String>();
        for (Integer i = 0; i < 3; i++) {
            fieldSubList.add(fieldList[i].QualifiedApiName);
        }
        Boolean result = Field_PesmissionHelper.enableFieldVisibility('Account', fieldSubList);
        system.assertEquals(result, TRUE);
    }
}
