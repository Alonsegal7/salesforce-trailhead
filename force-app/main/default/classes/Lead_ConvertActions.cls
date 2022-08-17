public without sharing class Lead_ConvertActions {

    public static Set<Id> clonedFeedsIds {
        get {
            if (clonedFeedsIds == null) clonedFeedsIds = new Set<Id>();
            return clonedFeedsIds;
        }
        set;
    }

    private static map<string,List<String>> feed_Objs_Describe {
        get {
            if (feed_Objs_Describe == null) {
                feed_Objs_Describe = new map<string,List<String>>();
                List<Schema.DescribeSobjectResult> results= Schema.describeSObjects(new List<string>{'FeedItem','FeedComment'});
                for(Integer i=0; i<results.size(); i++){
                    feed_Objs_Describe.put(results[i].getName(), new List<String>(results[i].fields.getMap().keySet()));
                }
            }
            return feed_Objs_Describe;
        }
        set;
    }

    public static void postConvertActions(List<Lead> newLeads_list, Map<Id,Lead> oldLeads_map){
        List<Lead> convertedLeads_list = new List<Lead>();
        for(Lead leadRec : newLeads_list){   
            if (oldLeads_map!= null && leadRec.IsConverted == true && oldLeads_map.get(leadRec.Id).IsConverted == false){
                convertedLeads_list.add(leadRec);
            }
        }
        if(convertedLeads_list.isEmpty()) return;
        updateAccOppCon_PostConvert(convertedLeads_list);
        moveRelatedFeedsToConOpp(convertedLeads_list);
    }

    private static void updateAccOppCon_PostConvert(List<Lead> convertedLeads_list){
        List<SObject> recordsToUpdate = new List<SObject>();
        for(Lead leadRec : convertedLeads_list){   
            if(leadRec.ConvertedAccountId != null){
                recordsToUpdate.add(new Account(Id=leadRec.ConvertedAccountId, ParentId=leadRec.Related_Company__c));
                if(leadRec.ConvertedOpportunityId != null){
                    recordsToUpdate.add(new Opportunity(Id=leadRec.ConvertedOpportunityId, Company__c=leadRec.Related_Company__c, Monday_Account__c=leadRec.ConvertedAccountId, pulse_account_ids__c=leadRec.primary_pulse_account_id__c));
                }
                if(leadRec.ConvertedContactId != null){
                    recordsToUpdate.add(new Contact(Id=leadRec.ConvertedContactId, Company__c=leadRec.Related_Company__c, Monday_Account__c=leadRec.ConvertedAccountId));
                }
            }
        }
        if(recordsToUpdate.isEmpty()) return;
        recordsToUpdate.sort();
        update recordsToUpdate;
    }

    private static void moveRelatedFeedsToConOpp(List<Lead> convertedLeads_list){
        Map<Id, Id> leadIdtoOppConIds = new Map<Id, Id>();

        for (Lead leadRec : convertedLeads_list) {
            if (leadRec.ConvertedOpportunityId != null) {
                leadIdtoOppConIds.put(leadRec.Id, leadRec.ConvertedOpportunityId);
            } else if(leadRec.ConvertedContactId != null){
                leadIdtoOppConIds.put(leadRec.Id, leadRec.ConvertedContactId);
            }
        }
        if(!leadIdtoOppConIds.isEmpty()) cloneFeeds(leadIdtoOppConIds);
    }

    private static void cloneFeeds(Map<Id, Id> leadIdtoOppConIds) {
        Set<Id> convertedLeadIdSet = leadIdtoOppConIds.keySet();
        String feedQuery = 'SELECT ' + String.join(feed_Objs_Describe.get('FeedItem'), ',');
        feedQuery += ' FROM FeedItem WHERE ParentId IN :convertedLeadIdSet';
        List<FeedItem> feedItemList = Database.query(feedQuery);
        if (feedItemList.isEmpty()) return;

        //feed item clone
        Map<Id, FeedItem> feedItemIdToNewFeedItemMap = new Map<Id, FeedItem>();
        for (FeedItem feedItemRec : feedItemList) {
            FeedItem newFeedItem = feedItemRec.clone(false, true, true, false);
            newFeedItem.ParentId = leadIdtoOppConIds.get(feedItemRec.ParentId);
            if (!clonedFeedsIds.contains(feedItemRec.id)) {
                feedItemIdToNewFeedItemMap.put(feedItemRec.id, newFeedItem);
                clonedFeedsIds.add(feedItemRec.id);
            }
        }

        Database.insert(feedItemIdToNewFeedItemMap.values(), false);
        
        Set<Id> feedItemIdSet = feedItemIdToNewFeedItemMap.keySet();
        feedQuery = 'SELECT ' + String.join(feed_Objs_Describe.get('FeedComment'), ',');
        feedQuery += ' FROM FeedComment WHERE FeedItemId IN: feedItemIdSet';
        List<FeedComment> feedCommentList = Database.query(feedQuery);
        if (feedCommentList.isEmpty()) return;

        //feed comment clone
        List<FeedComment> newFeedCommentList = new List<FeedComment>();
        for (FeedComment feedCommentRec : feedCommentList) {
            FeedComment newFeedComment = feedCommentRec.clone(false, true, true, false);
            newFeedComment.FeedItemId = feedItemIdToNewFeedItemMap.get(feedCommentRec.FeedItemId).Id;
            newFeedCommentList.add(newFeedComment);
        }
        Database.insert(newFeedCommentList, false);
    }
}