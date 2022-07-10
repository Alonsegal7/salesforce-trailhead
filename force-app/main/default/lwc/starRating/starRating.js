import { LightningElement, wire, api } from 'lwc';
import getSurveyInitData from '@salesforce/apex/starRatingController.getSurveyInitData';
import updateValues from '@salesforce/apex/starRatingController.updateValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class StarRating extends LightningElement {
    @api targetRecId;               //target record id
    @api objectApiName;             //target object api name 
    @api surveyName;                //survey name to query from CMT Star_Rating_Question__mdt
    @api title;                     //card title
    @api subtitle;                  //subtitle displayed under title in grey color 
    @api surveyFilledFieldApiName;  //Optional - checkbox field api name on the target object to mark that the survey was filled
    @api showSuccessToast = false;  //flag to display success toast when survey is submitted
    @api showLegend = false;        //Optional - display under the question a legend 1 star - do not agree 5 start - extremely agree
    @api showHiUsername = false;    //Optional - show a Hi, FirstName to the user at the top of the survey
    @api openTextFieldName;         //Optional - in case we want to display a comments open text this will be the api name of the field to map to
    load = false;
    questions = [];
    error;
    valuesMap = {};
    customError;
    hiUserFirstName;

    @wire(getSurveyInitData, { surveyName: '$surveyName', getCurrUserData: '$showHiUsername' }) 
    wiredSurveyInitData({ error, data }) {
        if (data) {
            try{
                this.questions = data.questions.map((item) => ({
                    ...item,
                    star1: item.Field_API_Name__c + '_1',
                    star2: item.Field_API_Name__c + '_2',
                    star3: item.Field_API_Name__c + '_3',
                    star4: item.Field_API_Name__c + '_4',
                    star5: item.Field_API_Name__c + '_5'
                }));
                if(data.currUserFirstName) this.hiUserFirstName = 'Hi ' + data.currUserFirstName + '!';
                this.error = undefined;
                this.load = true;
            } catch(e){
                console.error(e);
                console.error('e.name => ' + e.name );
                console.error('e.message => ' + e.message );
                console.error('e.stack => ' + e.stack );
            }
        } else if (error) {
            this.error = error;
            this.questions = undefined;
        }
    }
    
    rating(event) {
        let fieldName = event.target.name;
        let fieldValue = event.target.value;
        this.valuesMap[fieldName] = fieldValue;
    }

    saveValues() {
        this.customError = undefined;
        console.log('StarRating targetRecId: ' + this.targetRecId);
        console.log('StarRating objectApiName: '+ this.objectApiName);
        console.log('StarRating valuesMap: '+ JSON.stringify(this.valuesMap));
        var validAnswers = this.validateInput();
        if(validAnswers){
            this.updateTargetRecord();
        } else {
            this.customError = 'Please fill all the questions';
        }
    }

    updateTargetRecord(){
        let openText = {};
        if(this.openTextFieldName){
            openText['fieldname'] = this.openTextFieldName;
            openText['value'] = this.template.querySelector('lightning-textarea').value;
        }
        updateValues({
            recordId: this.targetRecId,
            objectApiName: this.objectApiName,
            valuesMap: this.valuesMap,
            openText: openText,
            surveyFilledField: this.surveyFilledFieldApiName
        }).then(result => {
            console.log('StarRating updateValues result: '+JSON.stringify(result));
            this.load = false;
            this.error = undefined;
            if(this.showSuccessToast) this.popSuccessToast();
            this.sendSurveyFilledEvent();
        }).catch(error => {
            console.log('StarRating updateValues error: '+JSON.stringify(error));
            this.error = error;
        });
    }

    sendSurveyFilledEvent(){
        const surveyFilledEvent = new CustomEvent("surveyfilled", {
            detail: this.targetRecId
        });
        this.dispatchEvent(surveyFilledEvent);
    }

    popSuccessToast(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.title + ' Submitted Successfully!',
                variant: 'success',
            }),
        );
    }

    validateInput(){
        console.log('checking all questions were answered...');
        var answersCount = Object.keys(this.valuesMap).length;
        var questionsCount = this.questions.length;
        console.log('StarRating answers count: '+ answersCount);
        console.log('StarRating questions count: '+ questionsCount);
        if(questionsCount == answersCount) {
            console.log('result: all questions were answered');
            return true;
        } else {
            console.log('result: '+ (questionsCount-answersCount) +' questions were not answered');
            return false;
        }
    }
}