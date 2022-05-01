import { LightningElement, wire, api } from 'lwc';
import getQuestionsList from '@salesforce/apex/starRatingController.getQuestionsList';
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
    load = false;
    questions = [];
    error;
    valuesMap = {};
    customError;

    @wire(getQuestionsList, { surveyName: '$surveyName' }) 
    wiredQuestions({ error, data }) {
        if (data) {
            this.questions = data.map((item) => ({
                ...item,
                star1: item.Field_API_Name__c + '_1',
                star2: item.Field_API_Name__c + '_2',
                star3: item.Field_API_Name__c + '_3',
                star4: item.Field_API_Name__c + '_4',
                star5: item.Field_API_Name__c + '_5'
            }));
            this.error = undefined;
            this.load = true;
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
        updateValues({
            recordId: this.targetRecId,
            objectApiName: this.objectApiName,
            valuesMap: this.valuesMap,
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