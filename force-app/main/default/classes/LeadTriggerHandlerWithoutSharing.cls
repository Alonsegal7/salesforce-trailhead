public without sharing class LeadTriggerHandlerWithoutSharing {
    
    public static Set<Id> clonedFeedsIds;
    
    public LeadTriggerHandlerWithoutSharing() {
        if (clonedFeedsIds == null)
            clonedFeedsIds = new Set<Id>();
    }
    
    public void afterInsert(Map<Id, Lead> oldLeadMap, Map<Id, Lead> newLeadMap) {
        moveRelatedFeedsOnConvert(oldLeadMap, newLeadMap);
    }
    
    public void moveRelatedFeedsOnConvert(Map<Id, Lead> oldLeadMap, Map<Id, Lead> newLeadMap) {
        try {
            Set<Id> convertedLeadIdSet = new Set<Id>();
            for (Lead lead_i: newLeadMap.values()) {
                if (lead_i.IsConverted == true && lead_i.IsConverted != oldLeadMap.get(lead_i.Id).IsConverted) {
                    convertedLeadIdSet.add(lead_i.Id);
                }
            }
            
            Map<Id, Id> leadIdtoOpportunityId = new Map<Id, Id>();
            Map<Id, Id> leadIdtoContactId = new Map<Id, Id>();
            
            for (Id leadId : convertedLeadIdSet) {
                if (newLeadMap.get(leadId).ConvertedOpportunityId != null) {
                    leadIdtoOpportunityId.put(leadId, newLeadMap.get(leadId).ConvertedOpportunityId);
                } else {
                    leadIdtoContactId.put(leadId, newLeadMap.get(leadId).ConvertedContactId);
                }
            }
            cloneFeeds(leadIdtoOpportunityId);
            cloneFeeds(leadIdtoContactId);
        } catch(Exception ex) {
            System.debug('Exception: ' + ex.getMessage() + ' (' + ex.getLineNumber() + ')');
        }
    }
    
    private void cloneFeeds(Map<Id, Id> leadIdtoSObjectId) {
        
        List<FeedItem> feedItemList = new List<FeedItem>();
        List<FeedComment> feedCommentList = new List<FeedComment>();
        Map<Id, FeedItem> feedItemIdToNewFeedItemMap = new Map<Id, FeedItem>();
        List<FeedComment> newFeedCommentList = new List<FeedComment>();
        Set<Id> feedItemIdSet = new Set<Id>();
        
        Set<Id> convertedLeadIdSet = leadIdtoSObjectId.keySet();
        
        String feedQuery = 'SELECT ' + String.join(getSObjectFields('FeedItem'), ',');
        feedQuery += ' FROM FeedItem WHERE ParentId IN :convertedLeadIdSet';
        feedItemList = Database.query(feedQuery);
        
        if (feedItemList.isEmpty()) {
            return;
        }
        for (FeedItem feedItem_i : feedItemList) {
            FeedItem newFeedItem = feedItem_i.clone(false, true, true, false);
            newFeedItem.ParentId = leadIdtoSObjectId.get(feedItem_i.ParentId);
            if (!clonedFeedsIds.contains(feedItem_i.id)) {
                feedItemIdToNewFeedItemMap.put(feedItem_i.id, newFeedItem);
                clonedFeedsIds.add(feedItem_i.id);
            }
            
        }
        Database.insert(feedItemIdToNewFeedItemMap.values(), false);
        
        feedItemIdSet = feedItemIdToNewFeedItemMap.keySet();
        feedQuery = 'SELECT ' + String.join(getSObjectFields('FeedComment'), ',');
        feedQuery += ' FROM FeedComment WHERE FeedItemId IN: feedItemIdSet';
        feedCommentList = Database.query(feedQuery);
        
        if (!feedCommentList.isEmpty()) {
            for (FeedComment feedComment_i : feedCommentList) {
                FeedComment newFeedComment = feedComment_i.clone(false, true, true, false);
                newFeedComment.FeedItemId = feedItemIdToNewFeedItemMap.get(feedComment_i.FeedItemId).Id;
                newFeedCommentList.add(newFeedComment);
            }
            Database.insert(newFeedCommentList, false);
        }
    }
    
    private List<String> getSObjectFields(String sObjectName) {
        List<String> fieldList = new List<String>();
        SObjectType objectType = Schema.getGlobalDescribe().get(sObjectName);
        Map<String, Schema.SObjectField> objectFieldMap = objectType.getDescribe().fields.getMap();
        for (String field_i : objectFieldMap.keySet()) {
            Schema.DescribeFieldResult dfr_i = objectFieldMap.get(field_i).getDescribe();
            if (dfr_i.isAccessible() && dfr_i.isCreateable()) {
                fieldList.add( String.valueOf(objectFieldMap.get(field_i)) );
            }
        }
        return fieldList;
    }

}