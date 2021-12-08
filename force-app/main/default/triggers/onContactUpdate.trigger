trigger onContactUpdate on Contact (after insert, after update, after delete) {
    if(Trigger.isAfter && Trigger.isUpdate){
        if(CreatePartnerUserCtrl.firstRun) {
            CreatePartnerUserCtrl.createUsersForApprovedContacts(Trigger.new, Trigger.oldMap);
            CreatePartnerUserCtrl.sendWelcomeEmails(Trigger.new, Trigger.oldMap);
            CreatePartnerUserCtrl.updateEligibleForCommissionOnUser(Trigger.new, Trigger.oldMap);
        }
    }
}