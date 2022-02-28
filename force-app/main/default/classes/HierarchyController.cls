public class HierarchyController {
    /**
     * Class Name : WrapperData
     * About : Structure wrapper data
     */
    public class WrapperData {
      @AuraEnabled
      public Object record;
      @AuraEnabled
      public Boolean hasChildrenContent;
      public WrapperData(Object record, Boolean hasChildrenContent) {
        this.record = record;
        this.hasChildrenContent = hasChildrenContent;
      }
    }
  
    @AuraEnabled
    public static WrapperData getTopParent(Id recordId, String soql) {
        String zeroSOQL = soql;
        zeroSOQL += ' WHERE Id = ' + '\'' + recordId + '\'';
        SObject topParent = Database.query(zeroSOQL);
        return new WrapperData(topParent, false);
    }

    /**
     * Method Name : getRecordData()
     * About : this method return wrapper of Hierarchy Data
     */
    @AuraEnabled
    public static List<WrapperData> getRecordData(
      String soql,
      String parentField,
      String recordId
    ) {
      String companyRtId = '0121t000000IQTiAAO';
      try {
        Map<Id, WrapperData> mapOfRecord = new Map<Id, WrapperData>();
        String firstSOQL = soql, secondSOQL = soql;
        //Get the Parent Record
        firstSOQL += ' WHERE ' + parentField + ' = ' + '\'' + recordId + '\'';
        if (soql.contains('FROM Account')) {
          firstSOQL += 'AND RecordTypeId = ' + '\'' + companyRtId + '\'';
        }
        for (sObject obj : Database.query(firstSOQL)) {
            mapOfRecord.put((Id) obj.get('Id'), new WrapperData(obj, false));
            // mapOfRecord.get((Id) topParent.get('Id')).hasChildrenContent = true;
        }
        Set<Id> setOfKeys = mapOfRecord.keySet();
        //Check If Parent Record has children or not
        secondSOQL += ' WHERE ' + parentField + ' IN : setOfKeys ';
        if (soql.contains('FROM Account')) {
          secondSOQL += 'AND RecordTypeId = ' + '\'' + companyRtId + '\'';
        }
        for (sObject obj : Database.query(secondSOQL)) {
            if (mapOfRecord.containsKey((Id) obj.get(parentField))) {
                mapOfRecord.get((Id) obj.get(parentField)).hasChildrenContent = true;
            }
        }

        return mapOfRecord.values();
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }
  }