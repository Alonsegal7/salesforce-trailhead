public with sharing class TeamTargetsCreation {
    
    public static Id teamTargetRtId = Schema.SObjectType.Target__c.getRecordTypeInfosByDeveloperName().get('Team_Target').getRecordTypeId();

    @AuraEnabled(Cacheable=false)
    public static List<Target__c> findExistingTeamTargets(Integer year, Id ownerId) {
        System.debug('Michael TeamTargetsCreation Class - Starting findExistingTeamTargets. Year is: '+year+' OwnerId is: '+ownerId);
        List<Target__c> targets = [SELECT id,Target_Date__c,Amount__c, Month__c,Year_Month__c,Period__c FROM Target__c  WHERE RecordTypeId =:teamTargetRtId AND Year__c =:year AND Team_Leader__c =: ownerId ORDER BY Month__c ASC];
        System.debug('Michael TeamTargetsCreation Class - Query result for findExistingTeamTargets is: '+targets);
        User teamLeader = [Select Id, Team__c FROM User WHERE Id =: ownerId LIMIT 1];
        
        //In case no Team Targets found for the user- create
        if (targets.isempty()) {
            for (Integer i = 1; i < 13; i++) {
                targets.add(new Target__c(
                    RecordTypeId = teamTargetRtId,
                    Target_Date__c = Date.newInstance(year, i, 1),
                    Team_Leader__c = ownerId,
                    Name = 'temp'+i,
                    Period__c = 'Monthly',
                    Amount__c = 0,
                    Team__c = teamLeader.Team__c
                    ));
                }
            System.debug('Michael TeamTargetsCreation Class - New targets created: '+targets);
        }
        
        //In case only some of the targets for the year exist, this is an edge case since team targets should only be created for the entire year
        else if (targets.size()<12) {
            System.debug('Michael TeamTargetsCreation Class - Identified that sone targets are missing. Target list lenght is '+targets.size());
            Map<Integer,Target__c> targetsByMonth = new Map<Integer,Target__c>();
            for (Target__c t : targets) {
                targetsByMonth.put(Integer.valueOf(t.Month__c),t);
            }
            for (Integer i = 1; i < 13; i++) {
                if (!targetsByMonth.containsKey(i)) {
                    System.debug('Target missing for: '+i+'. creating new target');
                    targets.add(new Target__c(
                        RecordTypeId = teamTargetRtId,
                        Target_Date__c = Date.newInstance(year, i, 1),
                        Team_Leader__c = ownerId,
                        Name = 'temp'+i,
                        Period__c = 'Monthly',
                        Amount__c = 0,
                        Team__c = teamLeader.Team__c
                        ));
                }
            }
            System.debug('Michael TeamTargetsCreation Class - Completed targets creation for missing months. Updated target list lenght is '+targets.size());
        }
        return targets;
    }

    @AuraEnabled(Cacheable=false)
    public static List<Target__c> upsertTargets(List<Target__c>finalTargets){

        if (!finalTargets.isempty()) {
            try {
                upsert finalTargets;
            } 
            catch(Exception e) {
                System.debug('Message: ' + e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
        }
        return finalTargets;
    }
}